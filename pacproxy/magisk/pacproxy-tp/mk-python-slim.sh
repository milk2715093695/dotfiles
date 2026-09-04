#!/bin/sh
# pacproxy-tp python 运行时裁剪脚本
# 输入: 完整 Termux python 包 tar.gz (bin/ lib/)
# 输出: dist/python-slim.tar.gz (46M -> 只保留 pacproxy 所需)
# 用法: ./mk-python-slim.sh /path/full-python.tar.gz
# 环境要求: 可运行 aarch64/arm64 二进制的系统 (macOS ARM 或 Linux arm64)

set -e
MODDIR="$(cd "$(dirname "$0")" && pwd)"
INPUT="${1:?用法: mk-python-slim.sh <full-python.tar.gz>}"
OUTDIR="$MODDIR/dist"
WORK="$OUTDIR/slim-work"
mkdir -p "$OUTDIR"

rm -rf "$WORK"
mkdir -p "$WORK"
tar -xzf "$INPUT" -C "$WORK"
S="$WORK"

# 必须项: bin/, lib/python3.10/, lib/libpython3.10.so*
# 所有删除均为 pacproxy.py import 闭包之外的模块

# --- 可删: 构建/头文件/文档 ---
rm -rf "$S/include" "$S/share" "$S/bin"/*-config*
# 可删: 打包工具 (pacproxy 不用 pip/setuptools)
rm -rf "$S/lib/python3.10/site-packages"
# 可删: distutils (仅打包用)
rm -rf "$S/lib/python3.10/distutils"
# 可删: 开发/UI/文档工具模块
for x in venv sqlite3 wsgiref xmlrpc curses ctypes pydoc_data multiprocessing email.mime test tkinter turtledemo idlelib lib2to3; do
    rm -rf "$S/lib/python3.10/$x" 2>/dev/null || true
done
# 可删: 纯 .py 顶层文档/测试/网络工具
for f in antigravity turtle pydoc doctest pickletools difflib pdb cgi cgitb imaplib smtplib ftplib nntplib telnetlib poplib socketserver; do
    rm -f "$S/lib/python3.10/$f.py" 2>/dev/null || true
done
# 清理 __pycache__
find "$S" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

echo "运行时大小: $(du -sh "$S" | cut -f1)"
# 重打包: 根目录保持原输入结构(单目录 python/ 或 bin+lib), build.sh 需解出 python/
# 约定输入 tar 根为 python/ (含 bin/ lib/), 直接重复归档即可
( cd "$WORK" && tar -czf "$OUTDIR/python-slim.tar.gz" python )
echo "裁剪完成: $OUTDIR/python-slim.tar.gz ($(du -h "$OUTDIR/python-slim.tar.gz" | cut -f1))"
