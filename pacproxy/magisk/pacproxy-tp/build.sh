#!/bin/sh
# pacproxy-tp Magisk zip 打包脚本
# 用法: PYTHON_TAR=/path/python-slim.tar.gz ./build.sh [版本]
# 产物: dist/pacproxy-tp-v<version>.zip
# 需要: 1) 已裁剪 python 运行时 tar.gz 2) python-slim 内有 bin/ lib/

set -e

MODDIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="${1:-v0.1.0}"
PYTHON_TAR="${PYTHON_TAR:-$MODDIR/dist/python-slim.tar.gz}"
OUTDIR="$MODDIR/dist"
OUT="$OUTDIR/pacproxy-tp-$VERSION.zip"
WORK="$OUTDIR/work"

if [ ! -f "$PYTHON_TAR" ]; then
    echo "缺失 python runtime: $PYTHON_TAR (先 mk-python-slim.sh 生成或从 Release 下载)" >&2
    exit 1
fi

rm -rf "$WORK"
mkdir -p "$WORK" "$OUTDIR"

# pacproxy.py 单源取自主版仓库 (pacproxy/pacproxy.py)，模块目录不保存副本
MAIN_PY="$(cd "$MODDIR/../.." && pwd)/pacproxy.py"
if [ ! -f "$MAIN_PY" ]; then
    echo "缺失主版 pacproxy.py: $MAIN_PY" >&2
    exit 1
fi

# 1) 模块源码
cp -R "$MODDIR/module.prop" "$MAIN_PY" "$MODDIR/service.sh" \
      "$MODDIR/watchdog.sh" "$MODDIR/update.sh" "$MODDIR/uninstall.sh" \
      "$MODDIR/NOTICE" "$MODDIR/LICENSES" "$WORK/"

# 2) python 运行时 (bin/lib)
"$(command -v tar)" -xzf "$PYTHON_TAR" -C "$WORK"

# 3) rules / user-overrides: 优先快照源目录, 无则为占位 (安装后 update.sh 填充)
mkdir -p "$WORK/rules" "$WORK/user-overrides"
if [ -d "$MODDIR/rules" ] && [ "$(ls -A "$MODDIR/rules" 2>/dev/null)" ]; then
    cp -f "$MODDIR"/rules/* "$WORK/rules/" 2>/dev/null
else
    touch "$WORK/rules/.gitkeep"
fi
if [ -d "$MODDIR/user-overrides" ] && [ "$(ls -A "$MODDIR/user-overrides" 2>/dev/null)" ]; then
    cp -f "$MODDIR"/user-overrides/* "$WORK/user-overrides/" 2>/dev/null
else
    touch "$WORK/user-overrides/.gitkeep"
fi
# 快照源存在时清理占位 (有真文件就不再留 .gitkeep)
[ -n "$(ls -A "$WORK/rules" 2>/dev/null | grep -v '^\.gitkeep$')" ] && rm -f "$WORK/rules/.gitkeep"
[ -n "$(ls -A "$WORK/user-overrides" 2>/dev/null | grep -v '^\.gitkeep$')" ] && rm -f "$WORK/user-overrides/.gitkeep"

# 4) 打包 (Magisk zip = 无 META-INF, 根为模块结构; 先删旧产物避免追加)
rm -f "$OUT"
(cd "$WORK" && zip -rq "$OUT" .)

echo "打包完成: $OUT ($(du -h "$OUT" | cut -f1))"
ls -la "$OUT"
