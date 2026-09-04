#!/usr/bin/env python3
"""pacproxy.py —— 复现 gfw-pac PAC 路由逻辑的本地转发代理，支持 HTTP 与透明劫持两种模式。

读取渲染合并后的规则文件（deploy 渲染期生成），启动时预计算路由表，运行期只做查表与转发。

用法:
    python3 pacproxy.py                          # 默认: HTTP 模式监听 127.0.0.1:6045, 上游 127.0.0.1:9910
    python3 pacproxy.py --listen 6046            # 换监听端口
    python3 pacproxy.py --upstream 127.0.0.1:7890
    python3 pacproxy.py --rules-dir ~/my/rules   # 换规则目录（默认 ~/.config/pacproxy）
    python3 pacproxy.py --transparent            # 透明劫持: 监听 0.0.0.0:6045, 由 iptables REDIRECT 注入, 需 root
    python3 pacproxy.py --test                   # 打印决策对拍后退出
"""

from __future__ import annotations

import argparse
import asyncio
import functools
import ipaddress
import logging
import logging.handlers
import socket
import struct
from dataclasses import dataclass
from pathlib import Path
from typing import Literal, TypeAlias
from urllib.parse import urlsplit

DEFAULT_LISTEN_HOST = "127.0.0.1"
DEFAULT_LISTEN_PORT = 6045
DEFAULT_UPSTREAM = "127.0.0.1:9910"
try:
    DEFAULT_RULES_DIR = Path.home() / ".config" / "pacproxy"
except RuntimeError:
    # Android su 会话无 HOME/PASSWORD，Path.home() 抛 "Could not determine home directory"。
    # 模块场景 --rules-dir/自定义环境总会显式传入，这里仅作兜底默认值。
    DEFAULT_RULES_DIR = Path("/nonexistent/pacproxy-rules")

# Linux 特有：iptables REDIRECT 劫持后原始目标地址的 getsockopt 选项（macOS 无此特性）
SO_ORIGINAL_DST = 80

# 路由决策结果类型：直接连接目标或经上游代理转发
Decision: TypeAlias = Literal["direct", "proxy"]

logger = logging.getLogger("pacproxy")


@dataclass(frozen=True)
class Rules:
    """启动时从 gfw-pac 源文件预计算出的静态路由表。"""

    direct_domains: frozenset[str]
    proxy_domains: frozenset[str]
    direct_groups: dict[int, frozenset[str]]
    proxy_groups: dict[int, frozenset[str]]
    local_tlds: frozenset[str]
    cn_v4: dict[int, frozenset[int]]  # IPv4 prefixlen -> 网络地址 int 集合
    cn_v6: dict[int, frozenset[int]]  # IPv6 prefixlen -> 网络地址 int 集合


@dataclass(frozen=True)
class ProxyConfig:
    """代理运行参数，全部可用 CLI 覆盖。"""

    listen_host: str = DEFAULT_LISTEN_HOST
    listen_port: int = DEFAULT_LISTEN_PORT
    upstream_host: str = "127.0.0.1"
    upstream_port: int = 9910
    rules_dir: Path = DEFAULT_RULES_DIR
    override_dir: Path | None = None
    transparent: bool = False
    verbose: bool = False
    log_path: Path | None = None

    @property
    def rule_files(self) -> dict[str, Path]:
        """渲染合并后的四份规则文件路径（deploy 渲染期生成）。

        叠加目录（override_dir）存在同名文件时，决策时按\"主文件 + 叠加文件\"合并
        读取（override 追加，去重保序见 _merged_lines），保证用户自定义规则可随改随生效。
        """

        def layered(name: str) -> Path:
            return self.rules_dir / name

        paths = {
            "direct": layered("direct-domains.txt"),
            "proxy": layered("proxy-domains.txt"),
            "tlds": layered("local-tlds.txt"),
            "cidrs": layered("cidrs-cn.txt"),
        }
        if self.override_dir is not None:
            paths["direct_ov"] = self.override_dir / "direct-domains.txt"
            paths["proxy_ov"] = self.override_dir / "proxy-domains.txt"
        return paths


def _setup_logging(verbose: bool, log_path: Path | None) -> None:
    """配置日志级别与输出目标。"""

    level = logging.DEBUG if verbose else logging.INFO

    handler: logging.Handler
    if log_path is not None:
        handler = logging.handlers.RotatingFileHandler(
            log_path, maxBytes=5 * 1024 * 1024, backupCount=3, encoding="utf-8"
        )
    else:
        handler = logging.StreamHandler()

    handler.setFormatter(
        logging.Formatter("%(asctime)s %(levelname)s %(message)s", datefmt="%H:%M:%S")
    )

    logger.setLevel(level)
    logger.addHandler(handler)


def _read_lines(path: Path) -> list[str]:
    """读取纯文本行，忽略空行；文件缺失时返回空列表。"""

    if not path.exists():
        return []

    return [
        line.strip()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]


def _group_by_length(domains: list[str]) -> dict[int, frozenset[str]]:
    """按域名长度分组，实现 O(1) 后缀匹配。"""

    groups: dict[int, set[str]] = {}
    for domain in domains:
        groups.setdefault(len(domain), set()).add(domain)

    return {
        length: frozenset(domains_at_length)
        for length, domains_at_length in groups.items()
    }


def _match_suffix(
    host: str,
    exact_domains: frozenset[str],
    groups: dict[int, frozenset[str]],
) -> bool:
    """判断 host 是否命中某个域名或其子域名。"""

    if host in exact_domains:
        return True

    for length, domains in groups.items():
        if (
            len(host) > length
            and host[-length - 1] == "."
            and host[-length:] in domains
        ):
            return True

    return False


def _is_private_literal(host: str) -> bool:
    """按 ipaddress 语义判断 host 是否为 IP 字面量且属于私网/回环/链路本地/未指定地址。

    非 IP 字面量（域名）返回 False，不会误判 "10.0.0.1.evil.com" 这类伪装域名。
    """

    try:
        address = ipaddress.ip_address(host)
    except ValueError:
        return False

    return (
        address.is_private
        or address.is_loopback
        or address.is_link_local
        or address.is_unspecified
    )


def _in_cn(
    ip_int: int,
    bit_width: int,
    v4: dict[int, frozenset[int]],
    v6: dict[int, frozenset[int]],
) -> bool:
    """按二进制前缀判断 IP 是否落在任一中国网段，等价于 PAC 的 radixTree。

    IPv4/IPv6 分表存储，按 bit_width 选表，避免跨族前缀长度撞键误判。

    Args:
        ip_int (int): 待判断地址的整数表示。
        bit_width (int): 地址位宽，IPv4=32、IPv6=128，用于选表与移位。
        v4 (dict[int, frozenset[int]]): IPv4 网段表，prefixlen -> 网络地址集合。
        v6 (dict[int, frozenset[int]]): IPv6 网段表，prefixlen -> 网络地址集合。

    Returns:
        bool: IP 落在任一中国网段时返回 True。
    """

    networks = v4 if bit_width == 32 else v6

    for prefix_len in networks:
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

        return {
            name: path.stat().st_mtime
            for name, path in self._paths.items()
            if path.exists()
        }

    def _merged_lines(self, name: str) -> list[str]:
        """读取单份规则文件，去重保序；文件缺失时为空。

        叠加规则存在（_ov 后缀 key）时一并读取合并；主文件优先，叠加追加。
        """

        lines = list(dict.fromkeys(_read_lines(self._paths[name])))
        ov_key = f"{name}_ov"
        if ov_key in self._paths:
            lines += [
                line
                for line in _read_lines(self._paths[ov_key])
                if line not in lines
            ]
        return lines

    def _load(self) -> Rules:
        """读取两份域名源与其余源文件，构建域名分组与 CIDR 前缀表。"""

        direct = self._merged_lines("direct")
        proxy = self._merged_lines("proxy")
        local_tlds = _read_lines(self._paths["tlds"])

        cn_v4: dict[int, set[int]] = {}
        cn_v6: dict[int, set[int]] = {}
        for cidr in _read_lines(self._paths["cidrs"]):
            network = ipaddress.ip_network(cidr, strict=False)
            prefix_bits = int(network.network_address) >> (
                network.max_prefixlen - network.prefixlen
            )
            bucket = cn_v4 if network.version == 4 else cn_v6
            bucket.setdefault(network.prefixlen, set()).add(prefix_bits)

        logger.info(
            "规则加载: %d 直连域名, %d 代理域名, %d 本地TLD, %d CIDR 前缀",
            len(direct),
            len(proxy),
            len(local_tlds),
            sum(len(addresses) for addresses in cn_v4.values())
            + sum(len(addresses) for addresses in cn_v6.values()),
        )

        return Rules(
            direct_domains=frozenset(direct),
            proxy_domains=frozenset(proxy),
            direct_groups=_group_by_length(direct),
            proxy_groups=_group_by_length(proxy),
            local_tlds=frozenset(local_tlds),
            cn_v4={prefix: frozenset(addresses) for prefix, addresses in cn_v4.items()},
            cn_v6={prefix: frozenset(addresses) for prefix, addresses in cn_v6.items()},
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

    def decide_ip(self, ip_text: str) -> Decision:
        """按 IP 字面值决策，供透明劫持模式使用（无 DNS、无域名规则）。

        Args:
            ip_text (str): 目标 IP 字符串。

        Returns:
            Decision: 私网或中国段直连，否则走代理。
        """

        if _is_private_literal(ip_text):
            return "direct"

        address = ipaddress.ip_address(ip_text)
        if _in_cn(
            int(address), address.max_prefixlen, self._rules.cn_v4, self._rules.cn_v6
        ):
            return "direct"

        return "proxy"

    async def _decide_host(self, host: str) -> Decision:
        """镜像 PAC `FindProxyForURL` 的分支顺序做路由决策。"""

        rules = self._rules

        if _match_suffix(host, rules.direct_domains, rules.direct_groups):
            return "direct"
        if _match_suffix(host, rules.proxy_domains, rules.proxy_groups):
            return "proxy"
        if "." not in host or host == "localhost":
            return "direct"  # isPlainHostName
        if host[host.rfind(".") :] in rules.local_tlds:
            return "direct"  # .test / .localhost
        if _is_private_literal(host):
            return "direct"  # isPrivateIp(host)

        try:
            address_infos = await asyncio.get_running_loop().getaddrinfo(
                host, None, proto=socket.IPPROTO_TCP
            )
        except OSError:
            logger.debug("DNS 解析失败 %s, 兜底走代理", host)
            return "proxy"  # dnsResolve 失败与 PAC 一致，兜底走代理

        # 任一解析结果命中直连（私网/中国段）即直连，与 PAC 的 dnsResolve 语义一致
        if any(self.decide_ip(str(item[4][0])) == "direct" for item in address_infos):
            return "direct"

        return "proxy"


async def _pipe(
    source: asyncio.StreamReader, destination: asyncio.StreamWriter
) -> None:
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
    lines = [
        line
        for line in rest_headers.split(b"\r\n")
        if not line.lower().startswith(hop_by_hop)
    ]

    return b"\r\n".join(lines)


def _parse_original_dst(sockaddr: bytes) -> tuple[int, str]:
    """解析 SO_ORIGINAL_DST 返回的 sockaddr_in，得到目标 (端口, IPv4)。

    Args:
        sockaddr (bytes): getsockopt 返回的原始 sockaddr_in 字节流。

    Returns:
        tuple[int, str]: 目标端口与 IPv4 字符串。

    Raises:
        ValueError: 地址族不是 AF_INET（如 IPv6）时抛出。
    """

    family = struct.unpack("=H", sockaddr[:2])[0]
    if family != socket.AF_INET:
        raise ValueError(f"不支持的地址族 {family}")

    port = struct.unpack("!H", sockaddr[2:4])[0]
    ip_text = socket.inet_ntoa(sockaddr[4:8])

    return port, ip_text


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
        logger.warning(
            "上游代理不可达 %s:%d: %s", config.upstream_host, config.upstream_port, exc
        )
        return None


async def _request_upstream_tunnel(
    upstream_reader: asyncio.StreamReader,
    upstream_writer: asyncio.StreamWriter,
    host: str,
    port: int,
) -> bool:
    """向上游代理发送 CONNECT 并等待 2xx 响应。

    Args:
        upstream_reader (StreamReader): 上游连接读端。
        upstream_writer (StreamWriter): 上游连接写端。
        host (str): 隧道目标主机名。
        port (int): 隧道目标端口。

    Returns:
        bool: 上游确认建立隧道时 True，否则 False。
    """

    connect_line = f"CONNECT {host}:{port} HTTP/1.1\r\nHost: {host}:{port}\r\n\r\n"
    upstream_writer.write(connect_line.encode())
    await upstream_writer.drain()

    try:
        status = (await upstream_reader.readuntil(b"\r\n\r\n")).split(b" ", 2)[1]
    except (asyncio.IncompleteReadError, asyncio.LimitOverrunError):
        logger.warning("上游对 CONNECT %s:%d 未返回状态行", host, port)
        return False

    if not status.startswith(b"2"):
        logger.warning(
            "上游拒绝 CONNECT %s:%d, status=%s",
            host,
            port,
            status.decode(errors="replace"),
        )
        return False

    return True


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
        if not await _request_upstream_tunnel(
            upstream_reader, upstream_writer, host, port
        ):
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

    host, port = parsed.hostname, parsed.port or (
        443 if parsed.scheme == "https" else 80
    )

    decision = await store.decide(host)
    logger.info("HTTP %s %s -> %s", method, url, decision)

    upstream = await _connect_target(config, host, port, decision)
    if upstream is None:
        await _write_http_error(writer, "502 Bad Gateway")
        return
    upstream_reader, upstream_writer = upstream

    if decision == "direct":
        path = (parsed.path or "/") + (("?" + parsed.query) if parsed.query else "")
        outgoing = f"{method} {path} {version}\r\n".encode() + _strip_hop_headers(
            rest_headers
        )
    else:
        outgoing = header  # 绝对路径形式直通 9910

    upstream_writer.write(outgoing)
    await upstream_writer.drain()

    await asyncio.gather(
        _pipe(reader, upstream_writer),
        _pipe(upstream_reader, writer),
        return_exceptions=True,
    )


async def _handle_transparent(
    store: RuleStore,
    config: ProxyConfig,
    reader: asyncio.StreamReader,
    writer: asyncio.StreamWriter,
) -> None:
    """处理透明劫持连接：读 SO_ORIGINAL_DST 拿真实目标，按 IP 决策后转发。

    客户端感知不到代理存在，因此不返回任何 HTTP 状态；失败路径统一关闭
    客户端连接（RST），让应用快速感知失败重试，等价 HTTP 模式的 502。
    """

    store.refresh()

    try:
        sock = writer.get_extra_info("socket")
        if sock is None:
            logger.debug("透明连接拿不到底层 socket")
            return

        try:
            port, ip_text = _parse_original_dst(
                sock.getsockopt(socket.SOL_IP, SO_ORIGINAL_DST, 16)
            )
        except (OSError, ValueError) as exc:
            logger.debug("读取 SO_ORIGINAL_DST 失败: %s", exc)
            return

        # 透明模式安全防护: 目标为本机回环+监听端口 = 自转发循环(外部连接到
        # 127.0.0.1:6045 的流量被 REDIRECT 进来, 若再连回自身端口会无限递归)。
        # 任何合法透明流量目标不可能是 pacproxy 自身监听端口, 直接丢弃。
        if ip_text.startswith("127.") and port == config.listen_port:
            logger.debug("透明连接目标为本机监听端口, 丢弃: %s", ip_text)
            return

        decision = store.decide_ip(ip_text)
        logger.info("透明 %s:%d -> %s", ip_text, port, decision)

        upstream = await _connect_target(config, ip_text, port, decision)
        if upstream is None:
            return
        upstream_reader, upstream_writer = upstream

        if decision != "direct":
            if not await _request_upstream_tunnel(
                upstream_reader, upstream_writer, ip_text, port
            ):
                upstream_writer.close()
                return

        await asyncio.gather(
            _pipe(reader, upstream_writer),
            _pipe(upstream_reader, writer),
            return_exceptions=True,
        )
    finally:
        writer.close()


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
    """打印一组 host 与 IP 的路由决策，供与 PAC 行为对拍验证。"""

    probe_hosts = [
        "api.openai.com",
        "chatgpt.com",
        "github.com",
        "www.bilibili.com",
        "www.baidu.com",
        "gitee.com",
        "opencode.ai",
        "unknownforeign.net",
        "localhost",
        "intranet-box",
        "foo.test",
    ]

    for host in probe_hosts:
        decision = await store.decide(host)
        print(f"{host:22} -> {decision}")

    probe_ips = [
        "10.0.0.5",
        "192.168.1.1",
        "172.16.0.1",
        "127.0.0.1",
        "223.5.5.5",
        "114.114.114.114",
        "1.1.1.1",
        "8.8.8.8",
        "2606:4700::1111",
        "2001:4860:4860::8888",
    ]

    for ip_text in probe_ips:
        decision = store.decide_ip(ip_text)
        print(f"{ip_text:22} -> {decision}")


async def _serve(store: RuleStore, config: ProxyConfig) -> None:
    """启动代理服务并保持运行。"""

    # 透明劫持模式的唯一用途是接收 iptables REDIRECT 注入，绑定 0.0.0.0；HTTP 模式默认绑 127.0.0.1
    listen_host = "0.0.0.0" if config.transparent else config.listen_host
    handler = (
        functools.partial(_handle_transparent, store, config)
        if config.transparent
        else functools.partial(_handle_connection, store, config)
    )

    try:
        server = await asyncio.start_server(handler, listen_host, config.listen_port)
    except OSError as exc:
        logger.error("监听失败 %s:%d: %s", listen_host, config.listen_port, exc)
        raise

    mode = "透明劫持" if config.transparent else "HTTP"
    logger.info(
        "pacproxy(%s) 监听 %s:%d, 直连 / 转发 %s:%d",
        mode,
        listen_host,
        config.listen_port,
        config.upstream_host,
        config.upstream_port,
    )

    if not config.transparent:
        logger.info(
            "export HTTPS_PROXY=http://%s:%d NO_PROXY=localhost,127.0.0.1",
            config.listen_host,
            config.listen_port,
        )

    async with server:
        await server.serve_forever()


def _parse_args() -> argparse.Namespace:
    """解析 CLI 参数，全部有默认值。"""

    parser = argparse.ArgumentParser(
        description="复现 gfw-pac 路由逻辑的本地转发代理（HTTP / 透明劫持）"
    )
    parser.add_argument(
        "--rules-dir",
        type=Path,
        default=DEFAULT_RULES_DIR,
        help=f"渲染合并后的规则目录（默认 {DEFAULT_RULES_DIR}）",
    )
    parser.add_argument(
        "--listen-host",
        default=DEFAULT_LISTEN_HOST,
        help=f"监听地址（默认 {DEFAULT_LISTEN_HOST}；透明模式强制 0.0.0.0）",
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
    parser.add_argument(
        "--transparent",
        action="store_true",
        help="透明劫持模式：读 SO_ORIGINAL_DST 决策并转发，监听 0.0.0.0",
    )
    parser.add_argument(
        "--test", action="store_true", help="打印决策对拍后退出，不启动服务"
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="输出 DEBUG 级别日志"
    )
    parser.add_argument(
        "--log", type=Path, default=None, help="日志文件路径（默认 stderr）"
    )
    parser.add_argument(
        "--override-dir",
        type=Path,
        default=None,
        help="用户自定义规则叠加目录（可选；同名文件与主规则合并读取）",
    )

    return parser.parse_args()


def _build_config(args: argparse.Namespace) -> ProxyConfig:
    """把 CLI 参数组装成 `ProxyConfig`。"""

    upstream_host, _separator, upstream_port = args.upstream.partition(":")

    return ProxyConfig(
        listen_host=args.listen_host,
        listen_port=args.listen,
        upstream_host=upstream_host,
        upstream_port=int(upstream_port or DEFAULT_UPSTREAM.split(":")[1]),
        rules_dir=args.rules_dir,
        override_dir=args.override_dir,
        transparent=args.transparent,
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
