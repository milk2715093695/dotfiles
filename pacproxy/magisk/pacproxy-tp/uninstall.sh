#!/system/bin/sh
# 卸载时清理 iptables + 停 pacproxy

iptables -w -t nat -D OUTPUT -j PAC_TP 2>/dev/null
iptables -w -t nat -D OUTPUT -p tcp -j PAC_TP 2>/dev/null
iptables -w -t nat -F PAC_TP 2>/dev/null
iptables -w -t nat -X PAC_TP 2>/dev/null
pkill -f "pacproxy.py.*transparent" 2>/dev/null

exit 0
