#!/system/bin/sh
# pacproxy 透明分流模块(自洽): 上游代理地址由 /data/adb/pacproxy-tp.conf 配置, 缺省 127.0.0.1:9910。
# 独立运行, 不依赖任何其他模块; 上游为假设的外部 HTTP 代理, 未就绪时直连流量不受影响, 代理请求按需失败。
# 改上游: 改 conf 后 sh service.sh start。用法: {start|stop}; Magisk late_start 无参=start。

MODDIR=${0%/*}
PYTHON="$MODDIR/python/bin/python3.10"
# 上游/下游/日志级别, 读 /data/adb/pacproxy-tp.conf (模块目录外, 升级不丢)
# conf 格式: UPSTREAM=127.0.0.1:9910 / PORT=6045 / VERBOSE=0
CONF=/data/adb/pacproxy-tp.conf
[ -f "$CONF" ] && . "$CONF"
UPSTREAM="${UPSTREAM:-127.0.0.1:9910}"
PORT="${PORT:-6045}"
LOGLEVEL_OPT=""
[ -n "$VERBOSE" ] && LOGLEVEL_OPT=" --verbose"
LOGDIR="$MODDIR/logs"
LOCKDIR="$LOGDIR/watchdog.lock"

unset LD_PRELOAD

start_service() {
    mkdir -p "$LOGDIR"
    # 停旧 watchdog: 锁目录内 pid (flock 失败后回退 mkdir 锁)
    if [ -r "$LOCKDIR/pid" ]; then
        kill "$(cat "$LOCKDIR/pid" 2>/dev/null)" 2>/dev/null
        sleep 1
    fi
    rm -rf "$LOCKDIR"

    # 等上游就绪(上游可能晚于本模块启动), 探测不了也照样起 pacproxy
    UPSTREAM_PORT=${UPSTREAM##*:}
    i=0
    while [ $i -lt 30 ]; do
        "$PYTHON" -c "import socket; socket.create_connection(('127.0.0.1', $UPSTREAM_PORT), 0.3)" 2>/dev/null && break
        sleep 1
        i=$((i + 1))
    done

    setsid "$PYTHON" "$MODDIR/pacproxy.py" \
        --rules-dir "$MODDIR/rules" \
        --override-dir "$MODDIR/user-overrides" \
        --upstream "$UPSTREAM" \
        --transparent \
        --listen "$PORT" \
        $LOGLEVEL_OPT \
        --log "$LOGDIR/pacproxy.log" \
        >> "$LOGDIR/pacproxy.log" 2>&1 &

    iptables -w -t nat -N PAC_TP 2>/dev/null
    iptables -w -t nat -F PAC_TP
    iptables -w -t nat -A PAC_TP -d 127.0.0.0/8 -j RETURN
    iptables -w -t nat -A PAC_TP -m owner --uid-owner 0 -j RETURN
    iptables -w -t nat -A PAC_TP -p tcp -j REDIRECT --to-ports "$PORT"
    iptables -w -t nat -C OUTPUT -p tcp -j PAC_TP 2>/dev/null \
        || iptables -w -t nat -A OUTPUT -p tcp -j PAC_TP
    setsid "$MODDIR/watchdog.sh" >> "$LOGDIR/watchdog.log" 2>&1 &
}

stop_service() {
    if [ -r "$LOCKDIR/pid" ]; then
        kill "$(cat "$LOCKDIR/pid" 2>/dev/null)" 2>/dev/null
        sleep 1
    fi
    rm -rf "$LOCKDIR"
    iptables -w -t nat -D OUTPUT -j PAC_TP 2>/dev/null
    iptables -w -t nat -D OUTPUT -p tcp -j PAC_TP 2>/dev/null
    iptables -w -t nat -F PAC_TP 2>/dev/null
    iptables -w -t nat -X PAC_TP 2>/dev/null
    pkill -f "pacproxy.py.*transparent" 2>/dev/null
}

case "$1" in
    start) start_service ;;
    stop) stop_service ;;
    *) start_service ;;
esac
