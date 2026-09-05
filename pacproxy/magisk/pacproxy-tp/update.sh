#!/system/bin/sh
# 更新规则: 拉取官方 gfw-pac + 合并 user-overrides, 重启 pacproxy。
# 用法: su -c sh /data/adb/modules/pacproxy-tp/update.sh

MODDIR=${0%/*}
PYTHON="$MODDIR/python/bin/python3.10"

unset LD_PRELOAD

"$PYTHON" "$MODDIR" <<'PYEOF' || exit 1
from __future__ import annotations

import pathlib
import sys
import urllib.error
import urllib.request

mod = pathlib.Path(sys.argv[1])
base = "https://raw.githubusercontent.com/zhiyi7/gfw-pac/master/"


def fetch(name: str) -> str:
    """拉取官方规则文件全文。"""
    try:
        return urllib.request.urlopen(base + name, timeout=30).read().decode("utf-8", "replace")
    except urllib.error.URLError as exc:
        raise SystemExit(f"[error] 拉取 {name} 失败: {exc}")


def read_optional(path: pathlib.Path) -> str:
    """读取可选叠加文件，缺失时返回空串。"""
    return path.read_text() if path.exists() else ""


def merge(official: str, override_path: pathlib.Path) -> str:
    """合并官方规则与用户叠加规则，去重保序。"""
    seen: set[str] = set()
    merged: list[str] = []
    for text in (official, read_optional(override_path)):
        for line in text.splitlines():
            line = line.strip()
            if line and line not in seen:
                seen.add(line)
                merged.append(line)
    return "\n".join(merged) + "\n"


def write_atomic(path: pathlib.Path, text: str) -> None:
    """原子写: 写临时文件再 rename(2) 替换, 读者永远看到完整文件(旧或新)。"""
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(text)
    tmp.chmod(0o644)
    tmp.replace(path)


rules = mod / "rules"
for name in ("direct-domains.txt", "proxy-domains.txt"):
    write_atomic(rules / name, merge(fetch(name), mod / "user-overrides" / name))
for name in ("local-tlds.txt", "cidrs-cn.txt"):
    write_atomic(rules / name, fetch(name))
print("规则已更新")
PYEOF

# 先停 watchdog(防其 10s 循环在 pkill 窗口内复活 pacproxy), 再停 pacproxy, 再启
if [ -r "$MODDIR/logs/watchdog.lock/pid" ]; then
    kill "$(cat "$MODDIR/logs/watchdog.lock/pid" 2>/dev/null)" 2>/dev/null
    sleep 1
fi
pkill -f "pacproxy.py.*transparent" 2>/dev/null
sleep 1
sh "$MODDIR/service.sh" start

exit 0
