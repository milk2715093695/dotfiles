# 执行 Termux 平台扩展配置
run_platform_deploy_units() {
    deploy_unit_tags="dev"
    run_deploy_unit "pacproxy" check_pacproxy_available "" "" render_pacproxy_config link_pacproxy_config ""
}

# 可用性 = 运行时软件存在（python3）；服务状态由 render/link 负责
check_pacproxy_available() {
    command -v python3 >/dev/null 2>&1
}

# 渲染 runit 服务目录与 run 脚本；缺失时初始化规则子模块
render_pacproxy_config() {
    local service_dir="$PREFIX/var/service/pacproxy"

    if [ -e "$REPO_ROOT/proxy/gfw-pac/.git" ]; then
        step "gfw-pac 子模块已就位，跳过初始化"
    else
        step "初始化 gfw-pac 规则子模块"
        git submodule update --init proxy/gfw-pac || {
            error "gfw-pac 子模块初始化失败"
            return 1
        }
    fi

    if [ ! -f "$REPO_ROOT/proxy/rules/new_direct.txt" ] || [ ! -f "$REPO_ROOT/proxy/rules/new_proxy.txt" ]; then
        warn "proxy/rules/ 缺少本地覆盖层（隐私文件，不入库）"
        warn "参考 proxy/rules/example_*.txt 创建 new_direct.txt / new_proxy.txt"
    fi

    mkdir -p "$service_dir/log"
    sed -e "s|__CONFIG_DIR__|$HOME/.local/share/pacproxy|g" \
        -e "s|__PYTHON__|$(command -v python3)|g" \
        "$REPO_ROOT/proxy/autostart/termux/pacproxy/run" > "$service_dir/run"
    chmod +x "$service_dir/run"

    cp "$REPO_ROOT/proxy/autostart/termux/pacproxy/log-run" "$service_dir/log/run"
    chmod +x "$service_dir/log/run"
}

# 链接 proxy/ -> ~/.local/share/pacproxy，并重启 runit 服务
link_pacproxy_config() {
    link_item "$HOME/.local/share/pacproxy" "$REPO_ROOT/proxy"

    if command -v sv >/dev/null 2>&1; then
        step "重启 pacproxy runit 服务（sv restart）"
        sv restart "$PREFIX/var/service/pacproxy" 2>/dev/null || true
    else
        warn "未找到 sv，服务将在下次开机由 Termux:Boot 拉起"
    fi
}