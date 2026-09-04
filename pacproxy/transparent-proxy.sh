#!/data/data/com.termux/files/usr/bin/bash
# 透明分流 iptables 规则管理（阶段 1 / Termux）。
# 依赖 pacproxy-tp 模块服务（Magisk, 0.0.0.0:6045 透明模式）与上游引擎（127.0.0.1:9910）。
# 用法: transparent-proxy.sh {start|stop|status}
# 需 root；start/stop 幂等。

set -u

PORT=6045
CHAIN=PAC_TP
# 排除 Termux 全部 uid（引擎 + pacproxy + 本 shell），防自环
TP_UID=$(stat -c %u /data/data/com.termux/files 2>/dev/null || echo 10349)
IPTABLES=iptables

cmd="${1:-status}"
case "$cmd" in
start)
  "$IPTABLES" -w -t nat -N "$CHAIN" 2>/dev/null
  "$IPTABLES" -w -t nat -F "$CHAIN"
  "$IPTABLES" -w -t nat -A "$CHAIN" -d 127.0.0.0/8 -j RETURN
  "$IPTABLES" -w -t nat -A "$CHAIN" -m owner --uid-owner "$TP_UID" -j RETURN
  "$IPTABLES" -w -t nat -A "$CHAIN" -p tcp -j REDIRECT --to-ports "$PORT"
  "$IPTABLES" -w -t nat -C OUTPUT -p tcp -j "$CHAIN" 2>/dev/null \
    || "$IPTABLES" -w -t nat -A OUTPUT -p tcp -j "$CHAIN"
  echo "transparent-proxy started (REDIRECT -> $PORT, exclude uid $TP_UID)"
  ;;
stop)
  "$IPTABLES" -w -t nat -D OUTPUT -j "$CHAIN" 2>/dev/null
  "$IPTABLES" -w -t nat -D OUTPUT -p tcp -j "$CHAIN" 2>/dev/null
  "$IPTABLES" -w -t nat -F "$CHAIN" 2>/dev/null
  "$IPTABLES" -w -t nat -X "$CHAIN" 2>/dev/null
  echo "transparent-proxy stopped"
  ;;
status)
  echo "== nat OUTPUT =="
  "$IPTABLES" -w -t nat -S OUTPUT
  echo "== nat $CHAIN =="
  "$IPTABLES" -w -t nat -S "$CHAIN" 2>/dev/null || echo "(chain not present)"
  ;;
*)
  echo "usage: $0 {start|stop|status}" >&2
  exit 1
  ;;
esac
