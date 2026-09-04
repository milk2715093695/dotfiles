#!/system/bin/sh
# pacproxy 保活 + iptables 兜底:
#   - 每 10s 查 pacproxy 进程, 挂了重启。连续失败 3 次退避 5min 防刷屏。
#   - iptables PAC_TP 被第三方清掉时幂等重加。
# 上游/下游/日志级别取自 /data/adb/pacproxy-tp.conf (模块目录外, 升级不丢); 与 service.sh 同源
MODDIR=${0%/*}
PYTHON="$MODDIR/python/bin/python3.10"
CONF=/data/adb/pacproxy-tp.conf
[ -f "$CONF" ] && . "$CONF"
UPSTREAM="${UPSTREAM:-127.0.0.1:9910}"
PORT="${PORT:-6045}"
LOGLEVEL_OPT=""
[ -n "$VERBOSE" ] && LOGLEVEL_OPT=" --verbose"
LOGDIR="$MODDIR/logs"
WATCHDOG_PID="$LOGDIR/watchdog.pid"
unset LD_PRELOAD

echo $$ > "$WATCHDOG_PID"
trap '[ "$(cat "$WATCHDOG_PID" 2>/dev/null)" = "$$" ] && rm -f "$WATCHDOG_PID"' EXIT

LAUNCH() {
    setsid "$PYTHON" "$MODDIR/pacproxy.py" --rules-dir "$MODDIR/rules" --override-dir "$MODDIR/user-overrides" --upstream "$UPSTREAM" --transparent --listen "$PORT" $LOGLEVEL_OPT --log "$LOGDIR/pacproxy.log" >> "$LOGDIR/pacproxy.log" 2>&1 &
    echo "watchdog: 启动 pacproxy, 上游=$UPSTREAM" >> "$LOGDIR/pacproxy.log"
}

pgrep -f "pacproxy.py.*transparent" >/dev/null 2>&1 || LAUNCH
tries=0
while true; do
    sleep 10
    iptables -w -t nat -C OUTPUT -p tcp -j PAC_TP 2>/dev/null || {
        iptables -w -t nat -N PAC_TP 2>/dev/null
        iptables -w -t nat -F PAC_TP
        iptables -w -t nat -A PAC_TP -d 127.0.0.0/8 -j RETURN
        iptables -w -t nat -A PAC_TP -m owner --uid-owner 0 -j RETURN
        iptables -w -t nat -A PAC_TP -p tcp -j REDIRECT --to-ports "$PORT"
        iptables -w -t nat -A OUTPUT -p tcp -j PAC_TP
        echo "watchdog: 重加 iptables PAC_TP" >> "$LOGDIR/pacproxy.log"
    }
    pgrep -f "pacproxy.py.*transparent" >/dev/null 2>&1 && { tries=0; continue; }
    tries=$((tries + 1))
    if [ $tries -ge 3 ]; then
        echo "watchdog: pacproxy 连续 3 次起不来, 退避 5min" >> "$LOGDIR/pacproxy.log"
        sleep 300
        tries=0
        continue
    fi
    echo "watchdog: pacproxy 挂了, 重启 (tries=$tries)" >> "$LOGDIR/pacproxy.log"
    LAUNCH
done
