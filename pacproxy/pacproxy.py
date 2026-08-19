#!/usr/bin/env python3
"""pacproxy.py —— 复现 gfw-pac PAC 路由逻辑的本地转发代理。

读取渲染合并后的规则文件（deploy 渲染期生成），启动时预计算路由表，运行期只做查表与转发。

用法:
    python3 pacproxy.py                          # 默认: 监听 127.0.0.1:6045, 上游 127.0.0.1:9910
    python3 pacproxy.py --listen 6046            # 换监听端口
    python3 pacproxy.py --upstream 127.0.0.1:7890
    python3 pacproxy.py --rules-dir ~/my/rules   # 换规则目录（默认 ~/.config/pacproxy）
    python3 pacproxy.py --test                   # 打印决策对拍后退出
"""

from __future__ import annotations

import argparse
import asyncio
import ipaddress
import logging
import logging.handlers
import re
import socket
from dataclasses import dataclass
from pathlib import Path
from typing import Literal
from urllib.parse import urlsplit

DEFAULT_LISTEN_HOST = "127.0.0.1"
DEFAULT_LISTEN_PORT = 6045
DEFAULT_UPSTREAM = "127.0.0.1:9910"
DEFAULT_RULES_DIR = Path.home() / ".config" / "pacproxy"

# 路由决策结果类型：直接连接目标或经上游代理转发
Decision = Literal["direct", "proxy"]

# 镜像 PAC isPrivateIp：IPv4 分支锚定首尾，防止 "10.0.0.1.evil.com" 这类域名误判
_PRIVATE_IP_RE = re.compile(
    r"^(::ffff:)?(10\.([0-9]{1,3}\.){2}[0-9]{1,3}$"
    r"|192\.168\.([0-9]{1,3}\.){2}[0-9]{1,3}$"
    r"|172\.(1[6-9]|2[0-9]|3[01])\.([0-9]{1,3}\.){2}[0-9]{1,3}$"
    r"|127\.([0-9]{1,3}\.){2}[0-9]{1,3}$"
    r"|169\.254\.([0-9]{1,3}\.){2}[0-9]{1,3}$)"
    r"|^f[cd][0-9a-f]{2}:|^fe80:|^::1$|^::$",
    re.IGNORECASE,
)

logger = logging.getLogger("pacproxy")


@dataclass(frozen=True)
class Rules:
    """启动时从 gfw-pac 源文件预计算出的静态路由表。"""

    direct_domains: frozenset[str]
    proxy_domains: frozenset[str]
    direct_groups: dict[int, frozenset[str]]
    proxy_groups: dict[int, frozenset[str]]
    local_tlds: frozenset[str]
    cn_networks: dict[int, frozenset[int]]  # prefixlen -> 网络地址 int 集合


@dataclass(frozen=True)
class ProxyConfig:
    """代理运行参数，全部可用 CLI 覆盖。"""

    listen_host: str = DEFAULT_LISTEN_HOST
    listen_port: int = DEFAULT_LISTEN_PORT
    upstream_host: str = "127.0.0.1"
    upstream_port: int = 9910
    rules_dir: Path = DEFAULT_RULES_DIR
    verbose: bool = False
    log_path: Path | None = None

    @property
    def rule_files(self) -> dict[str, Path]:
        """渲染合并后的四份规则文件路径（deploy 渲染期生成）。"""

        return {
            "direct": self.rules_dir / "direct-domains.txt",
            "proxy": self.rules_dir / "proxy-domains.txt",
            "tlds": self.rules_dir / "local-tlds.txt",
            "cidrs": self.rules_dir / "cidrs-cn.txt",
        }


def _setup_logging(verbose: bool, log_path: Path | None) -> None:
    """配置日志级别与输出目标。

    Args:
        verbose (bool): 为真时输出 DEBUG 级别日志。
        log_path (Path | None): 日志文件路径，为空时输出到 stderr。
    """

    level = logging.DEBUG if verbose else logging.INFO

    handler: logging.Handler
    if log_path is not None:
        handler = logging.handlers.RotatingFileHandler(
            log_path, maxBytes=5 * 1024 * 1024, backupCount=3, encoding="utf-8"
        )
    else:
        handler = logging.StreamHandler()

    handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(message)s", datefmt="%H:%M:%S"))

    logger.setLevel(level)
    logger.addHandler(handler)


def _read_lines(path: Path) -> list[str]:
    """读取纯文本行，忽略空行；文件缺失时返回空列表。"""

    if not path.exists():
        return []

    return [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def _group_by_length(domains: list[str]) -> dict[int, frozenset[str]]:
    """按域名长度分组，实现 O(1) 后缀匹配。"""

    groups: dict[int, set[str]] = {}
    for domain in domains:
        groups.setdefault(len(domain), set()).add(domain)

    return {length: frozenset(domains_set) for length, domains_set in groups.items()}


def _match_suffix(host: str, exact: frozenset[str], groups: dict[int, frozenset[str]]) -> bool:
    """判断 host 是否命中某个域名或其子域名。"""

    if host in exact:
        return True

    for length, domains in groups.items():
        if len(host) > length and host[-length - 1] == "." and host[-length:] in domains:
            return True

    return False


def _in_cn(ip_int: int, bit_width: int, networks: dict[int, frozenset[int]]) -> bool:
    """按二进制前缀判断 IP 是否落在任一中国网段，等价于 PAC 的 radixTree。"""

    for prefix_len in networks:
        if prefix_len > bit_width:
            continue
        if (ip_int >> (bit_width - prefix_len)) in networks[prefix_len]:
            return True

    return False


class RuleStore:
    """持有路由表，处理规则文件变更热载，并按 host 缓存决策。

    规则文件由 deploy 渲染期合并生成（官方 gfw-pac + 本地覆盖层），
    本类只读渲染后的单一来源；文件 mtime 变更时热载。
    """

    def __init__(
        self,
        paths: dict[str, Path],
    ) -> None:
        self._paths = paths
        self._rules = self._load()
        self._mtime = self._snapshot_mtime()
        self._decision_cache: dict[str, Decision] = {}

    def _snapshot_mtime(self) -> dict[str, float]:
        """记录各源文件 mtime（缺失文件跳过），用于检测手动更新。"""

        return {name: path.stat().st_mtime for name, path in self._paths.items() if path.exists()}

    def _merged_lines(self, name: str) -> list[str]:
        """读取单份规则文件，去重保序；文件缺失时为空。"""

        return list(dict.fromkeys(_read_lines(self._paths[name])))

    def _load(self) -> Rules:
        """读取两份域名源与其余源文件，构建域名分组与 CIDR 前缀表。"""

        direct = self._merged_lines("direct")
        proxy = self._merged_lines("proxy")
        local_tlds = _read_lines(self._paths["tlds"])

        cn_networks: dict[int, set[int]] = {}
        for cidr in _read_lines(self._paths["cidrs"]):
            network = ipaddress.ip_network(cidr, strict=False)
            prefix_bits = int(network.network_address) >> (network.max_prefixlen - network.prefixlen)
            cn_networks.setdefault(network.prefixlen, set()).add(prefix_bits)

        logger.info(
            "规则加载: %d 直连域名, %d 代理域名, %d 本地TLD, %d CIDR 前缀",
            len(direct),
            len(proxy),
            len(local_tlds),
            sum(len(addresses) for addresses in cn_networks.values()),
        )

        return Rules(
            direct_domains=frozenset(direct),
            proxy_domains=frozenset(proxy),
            direct_groups=_group_by_length(direct),
            proxy_groups=_group_by_length(proxy),
            local_tlds=frozenset(local_tlds),
            cn_networks={prefix: frozenset(addresses) for prefix, addresses in cn_networks.items()},
        )

    def refresh(self) -> None:
        """源文件 mtime 变化时重建路由表并清空决策缓存。"""

        current = self._snapshot_mtime()
        if current == self._mtime:
            return

        self._rules = self._load()
        self._mtime = current
        self._decision_cache.clear()

        logger.info("规则文件变更, 已热载, 决策缓存已清空")

    async def decide(self, host: str) -> Decision:
        """返回 host 的路由决策，结果按 host 缓存避免重复 DNS 查询。

        Args:
            host (str): 目标主机名，可能带端口。

        Returns:
            Decision: `direct` 或 `proxy`。
        """

        host = host.split(":")[0].lower()

        if host in self._decision_cache:
            logger.debug("决策缓存 hit: %s -> %s", host, self._decision_cache[host])
        else:
            self._decision_cache[host] = await self._decide_host(host)
            logger.debug("决策缓存 miss: %s -> %s", host, self._decision_cache[host])

        return self._decision_cache[host]

    async def _decide_host(self, host: str) -> Decision:
        """镜像 PAC `FindProxyForURL` 的分支顺序做路由决策。"""

        rules = self._rules

        if _match_suffix(host, rules.direct_domains, rules.direct_groups):
            return "direct"
        if _match_suffix(host, rules.proxy_domains, rules.proxy_groups):
            return "proxy"
        if "." not in host or host == "localhost":
            return "direct"  # isPlainHostName
        if host[host.rfind("."):] in rules.local_tlds:
            return "direct"  # .test / .localhost
        if _PRIVATE_IP_RE.search(host):
            return "direct"  # isPrivateIp(host)

        try:
            address_infos = await asyncio.get_running_loop().getaddrinfo(
                host, None, proto=socket.IPPROTO_TCP
            )
        except OSError:
            logger.debug("DNS 解析失败 %s, 兜底走代理", host)
            return "proxy"  # dnsResolve 失败与 PAC 一致，兜底走代理

        ip_addresses = [ipaddress.ip_address(item[4][0]) for item in address_infos]

        if any(_PRIVATE_IP_RE.search(str(address)) for address in ip_addresses):
            return "direct"
        if any(_in_cn(int(address), address.max_prefixlen, rules.cn_networks) for address in ip_addresses):
            return "direct"

        return "proxy"


async def _pipe(source: asyncio.StreamReader, destination: asyncio.StreamWriter) -> None:
    """把 source 的字节流单向复制到 destination，供隧道双向转发使用。"""

    try:
        while chunk := await source.read(65536):
            destination.write(chunk)
            await destination.drain()
    except (ConnectionError, OSError, asyncio.CancelledError):
        pass
    finally:
        destination.close()


async def _write_http_error(writer: asyncio.StreamWriter, status: str) -> None:
    """向客户端写入简短的 HTTP 错误响应。"""

    writer.write(f"HTTP/1.1 {status}\r\n\r\n".encode())
    await writer.drain()


def _strip_hop_headers(rest_headers: bytes) -> bytes:
    """直连场景移除代理专用 hop-by-hop 头，避免污染源站请求。"""

    hop_by_hop = (b"proxy-connection:", b"proxy-authorization:")
    lines = [line for line in rest_headers.split(b"\r\n") if not line.lower().startswith(hop_by_hop)]

    return b"\r\n".join(lines)


async def _connect_target(
    config: ProxyConfig,
    host: str,
    port: int,
    decision: Decision,
) -> tuple[asyncio.StreamReader, asyncio.StreamWriter] | None:
    """按决策建立上游连接；直连失败或上游不可达时记录日志并返回 None。

    Args:
        config (ProxyConfig): 代理运行参数。
        host (str): 目标主机名。
        port (int): 目标端口。
        decision (Decision): 路由决策，`direct` 直连目标，否则走上游代理。

    Returns:
        tuple[StreamReader, StreamWriter] | None: 连接读写对；失败时 None。
    """

    if decision == "direct":
        try:
            return await asyncio.open_connection(host, port)
        except OSError as exc:
            logger.warning("直连失败 %s:%d: %s", host, port, exc)
            return None

    try:
        return await asyncio.open_connection(config.upstream_host, config.upstream_port)
    except OSError as exc:
        logger.warning("上游代理不可达 %s:%d: %s", config.upstream_host, config.upstream_port, exc)
        return None


async def _tunnel(
    store: RuleStore,
    config: ProxyConfig,
    client_reader: asyncio.StreamReader,
    client_writer: asyncio.StreamWriter,
    host: str,
    port: int,
) -> None:
    """处理 CONNECT 请求：决策后建立上游隧道并双向转发。"""

    decision = await store.decide(host)
    logger.info("CONNECT %s:%d -> %s", host, port, decision)

    upstream = await _connect_target(config, host, port, decision)
    if upstream is None:
        await _write_http_error(client_writer, "502 Bad Gateway")
        return
    upstream_reader, upstream_writer = upstream

    if decision != "direct":
        connect_line = f"CONNECT {host}:{port} HTTP/1.1\r\nHost: {host}:{port}\r\n\r\n"
        upstream_writer.write(connect_line.encode())
        await upstream_writer.drain()

        try:
            status = (await upstream_reader.readuntil(b"\r\n\r\n")).split(b" ", 2)[1]
        except (asyncio.IncompleteReadError, asyncio.LimitOverrunError):
            logger.warning("上游对 CONNECT %s:%d 未返回状态行", host, port)
            await _write_http_error(client_writer, "502 Bad Gateway")
            upstream_writer.close()
            return

        if not status.startswith(b"2"):
            logger.warning(
                "上游拒绝 CONNECT %s:%d, status=%s",
                host,
                port,
                status.decode(errors="replace"),
            )
            await _write_http_error(client_writer, "502 Bad Gateway")
            upstream_writer.close()
            return

    client_writer.write(b"HTTP/1.1 200 Connection Established\r\n\r\n")
    await client_writer.drain()

    await asyncio.gather(
        _pipe(client_reader, upstream_writer),
        _pipe(upstream_reader, client_writer),
        return_exceptions=True,
    )


async def _handle_http(
    store: RuleStore,
    config: ProxyConfig,
    reader: asyncio.StreamReader,
    writer: asyncio.StreamWriter,
    header: bytes,
) -> None:
    """处理普通 HTTP 请求：决策后直连或原样转发给上游代理。"""

    request_line, rest_headers = header.split(b"\r\n", 1)
    method, url, version = request_line.decode(errors="replace").split(" ", 2)
    parsed = urlsplit(url)

    if parsed.hostname is None:
        await _write_http_error(writer, "400 Bad Request")
        return

    host, port = parsed.hostname, parsed.port or (443 if parsed.scheme == "https" else 80)

    decision = await store.decide(host)
    logger.info("HTTP %s %s -> %s", method, url, decision)

    upstream = await _connect_target(config, host, port, decision)
    if upstream is None:
        await _write_http_error(writer, "502 Bad Gateway")
        return
    upstream_reader, upstream_writer = upstream

    if decision == "direct":
        path = (parsed.path or "/") + (("?" + parsed.query) if parsed.query else "")
        outgoing = f"{method} {path} {version}\r\n".encode() + _strip_hop_headers(rest_headers)
    else:
        outgoing = header  # 绝对路径形式直通 9910

    upstream_writer.write(outgoing)
    await upstream_writer.drain()

    await asyncio.gather(
        _pipe(reader, upstream_writer),
        _pipe(upstream_reader, writer),
        return_exceptions=True,
    )


async def _handle_connection(
    store: RuleStore,
    config: ProxyConfig,
    reader: asyncio.StreamReader,
    writer: asyncio.StreamWriter,
) -> None:
    """代理入口：按 CONNECT / 普通 HTTP 分发请求。"""

    try:
        store.refresh()
        header = await reader.readuntil(b"\r\n\r\n")

        first_line = header.split(b"\r\n", 1)[0].decode(errors="replace")
        method, target, _version = first_line.split(" ", 2)

        if method == "CONNECT":
            host, _separator, port = target.partition(":")
            await _tunnel(store, config, reader, writer, host, int(port or 443))
        else:
            await _handle_http(store, config, reader, writer, header)
    except (asyncio.IncompleteReadError, asyncio.LimitOverrunError, ValueError):
        logger.debug("请求头不完整或非法, 关闭连接")
    except OSError as exc:
        logger.debug("连接读写异常: %s", exc)
    finally:
        writer.close()


async def _self_test(store: RuleStore) -> None:
    """打印一组 host 的路由决策，供与 PAC 行为对拍验证。"""

    probe_hosts = [
        "api.openai.com", "chatgpt.com", "github.com",
        "www.bilibili.com", "www.baidu.com", "gitee.com",
        "opencode.ai", "unknownforeign.net", "localhost", "intranet-box", "foo.test",
    ]

    for host in probe_hosts:
        decision = await store.decide(host)
        print(f"{host:22} -> {decision}")


async def _serve(store: RuleStore, config: ProxyConfig) -> None:
    """启动代理服务并保持运行。"""

    try:
        server = await asyncio.start_server(
            lambda reader, writer: _handle_connection(store, config, reader, writer),
            config.listen_host,
            config.listen_port,
        )
    except OSError as exc:
        logger.error("监听失败 %s:%d: %s", config.listen_host, config.listen_port, exc)
        raise

    logger.info(
        "pacproxy 监听 %s:%d, 直连 / 转发 %s:%d",
        config.listen_host,
        config.listen_port,
        config.upstream_host,
        config.upstream_port,
    )
    logger.info(
        "export HTTPS_PROXY=http://%s:%d NO_PROXY=localhost,127.0.0.1",
        config.listen_host,
        config.listen_port,
    )

    async with server:
        await server.serve_forever()


def _parse_args() -> argparse.Namespace:
    """解析 CLI 参数，全部有默认值。"""

    parser = argparse.ArgumentParser(description="复现 gfw-pac 路由逻辑的本地转发代理")
    parser.add_argument(
        "--rules-dir",
        type=Path,
        default=DEFAULT_RULES_DIR,
        help=f"渲染合并后的规则目录（默认 {DEFAULT_RULES_DIR}）",
    )
    parser.add_argument(
        "--listen",
        type=int,
        default=DEFAULT_LISTEN_PORT,
        help=f"监听端口（默认 {DEFAULT_LISTEN_PORT}）",
    )
    parser.add_argument(
        "--upstream",
        default=DEFAULT_UPSTREAM,
        help=f"上游 HTTP 代理 host:port（默认 {DEFAULT_UPSTREAM}）",
    )
    parser.add_argument("--test", action="store_true", help="打印决策对拍后退出，不启动服务")
    parser.add_argument("-v", "--verbose", action="store_true", help="输出 DEBUG 级别日志")
    parser.add_argument("--log", type=Path, default=None, help="日志文件路径（默认 stderr）")

    return parser.parse_args()


def _build_config(args: argparse.Namespace) -> ProxyConfig:
    """把 CLI 参数组装成 `ProxyConfig`。"""

    upstream_host, _separator, upstream_port = args.upstream.partition(":")

    return ProxyConfig(
        listen_port=args.listen,
        upstream_host=upstream_host,
        upstream_port=int(upstream_port or DEFAULT_UPSTREAM.split(":")[1]),
        rules_dir=args.rules_dir,
        verbose=args.verbose,
        log_path=args.log,
    )


def main() -> None:
    """CLI 入口：`--test` 打印决策对拍，默认启动代理服务。"""

    args = _parse_args()
    config = _build_config(args)
    _setup_logging(config.verbose, config.log_path)
    store = RuleStore(config.rule_files)

    try:
        if args.test:
            asyncio.run(_self_test(store))
        else:
            asyncio.run(_serve(store, config))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
