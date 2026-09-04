#!/system/bin/sh
# 更新规则: 拉取官方 gfw-pac + 合并 user-overrides, 重启 pacproxy。
# 用法: su -c sh /data/adb/modules/pacproxy-tp/update.sh

MODDIR=${0%/*}
PYTHON="$MODDIR/python/bin/python3.10"

unset LD_PRELOAD

"$PYTHON" "$MODDIR" <<'PYEOF' || exit 1
import pathlib
import sys
import urllib.request

mod = pathlib.Path(sys.argv[1])
base = "https://raw.githubusercontent.com/zhiyi7/gfw-pac/master/"


def fetch(name):
    return urllib.request.urlopen(base + name, timeout=30).read().decode("utf-8", "replace")


def merge(official, override_path):
    seen, out = set(), []
    for text in (official, pathlib.Path(override_path).read_text()):
        for line in text.splitlines():
            line = line.strip()
            if line and line not in seen:
                seen.add(line)
                out.append(line)
    return "\n".join(out) + "\n"


rules = mod / "rules"
rules.joinpath("direct-domains.txt").write_text(
    merge(fetch("direct-domains.txt"), mod / "user-overrides/direct-domains.txt")
)
rules.joinpath("proxy-domains.txt").write_text(
    merge(fetch("proxy-domains.txt"), mod / "user-overrides/proxy-domains.txt")
)
rules.joinpath("local-tlds.txt").write_text(fetch("local-tlds.txt"))
rules.joinpath("cidrs-cn.txt").write_text(fetch("cidrs-cn.txt"))
print("rules updated")
PYEOF

pkill -f "pacproxy.py.*transparent" 2>/dev/null
sleep 1
sh "$MODDIR/service.sh" start

exit 0
