#!/system/bin/sh
# pacproxy-tp customize.sh — Magisk 安装回调
# Magisk 解压后强制全文件 0644 (set_default_perm), 此处恢复可执行位
MODPATH="${MODPATH:-${0%/*}}"

chmod 755 "$MODPATH"/service.sh \
    "$MODPATH"/watchdog.sh \
    "$MODPATH"/update.sh \
    "$MODPATH"/uninstall.sh \
    "$MODPATH"/pacproxy.py \
    "$MODPATH"/python/bin/python3.10 \
    "$MODPATH"/python/bin/python3 \
    "$MODPATH"/python/bin/python \
    "$MODPATH"/python/bin/ld-musl-aarch64.so.1 2>/dev/null

ui_print "- 已恢复可执行位 (customize.sh)"