# 执行 Termux 平台扩展配置
run_platform_deploy_units() {
    deploy_unit_tags="dev"
    run_deploy_unit "pacproxy" check_pacproxy_available "" "" render_pacproxy_config link_pacproxy_config ""
}

# 可用性 = 运行时软件存在（python3）；服务状态由 render/link 负责
check_pacproxy_available() {
    command -v python3 >/dev/null 2>&1
}

# 渲染合并规则并生成 PAC；缺失时初始化规则子模块
render_pacproxy_config() {
    local service_dir="$PREFIX/var/service/pacproxy"

    if [ -e "$REPO_ROOT/pacproxy/gfw-pac/.git" ]; then
        step "gfw-pac 子模块已就位，跳过初始化"
    else
        step "初始化 gfw-pac 规则子模块"
        git submodule update --init pacproxy/gfw-pac || {
            error "gfw-pac 子模块初始化失败"
            return 1
        }
    fi

    render_pacproxy_assets

    mkdir -p "$service_dir/log"
    sed -e "s|__PYTHON__|$(command -v python3)|g" \
        "$REPO_ROOT/pacproxy/autostart/termux/pacproxy/run" > "$service_dir/run"
    chmod +x "$service_dir/run"

    cp "$REPO_ROOT/pacproxy/autostart/termux/pacproxy/log-run" "$service_dir/log/run"
    chmod +x "$service_dir/log/run"
}

# 链接 generated/pacproxy -> ~/.config/pacproxy，并重启 runit 服务
link_pacproxy_config() {
    link_item "$HOME/.config/pacproxy" "$REPO_ROOT/generated/pacproxy"

    if command -v sv >/dev/null 2>&1; then
        step "重启 pacproxy runit 服务（sv restart）"
        sv restart "$PREFIX/var/service/pacproxy" 2>/dev/null || true
    else
        warn "未找到 sv，服务将在下次开机由 Termux:Boot 拉起"
    fi
}