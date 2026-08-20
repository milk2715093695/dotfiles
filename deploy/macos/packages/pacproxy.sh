# pacproxy 本地转发代理部署单元（macOS）
# 依赖 gfw-pac 规则子模块；启动项走 autostart 通用层（launchd 自启）；~/.config/pacproxy -> 仓库 generated/pacproxy

# 可用性 = 运行时软件存在（python3）；服务状态由 render/link 负责
check_pacproxy_available() {
    command -v python3 >/dev/null 2>&1
}

# 渲染合并规则并生成 PAC；缺失时初始化规则子模块
render_pacproxy_config() {
    git -C "$REPO_ROOT" submodule update --init pacproxy/gfw-pac || {
        error "gfw-pac 子模块初始化失败"
        return 1
    }

    render_pacproxy_assets
}

# 链接 generated/pacproxy -> ~/.config/pacproxy，并注册 launchd 自启（autostart 通用层）
link_pacproxy_config() {
    link_item "$HOME/.config/pacproxy" "$REPO_ROOT/generated/pacproxy"

    register_autostart pacproxy \
        "s|__PYTHON__|$(command -v python3)|g" \
        "s|~/.config/pacproxy|$HOME/.config/pacproxy|g"
}
