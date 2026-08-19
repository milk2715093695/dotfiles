# pacproxy 本地转发代理部署单元（macOS）
# 依赖 gfw-pac 规则子模块；launchd 自启；~/.config/pacproxy -> 仓库 generated/pacproxy

# 可用性 = 运行时软件存在（python3）；服务状态由 render/link 负责
check_pacproxy_available() {
    command -v python3 >/dev/null 2>&1
}

# 渲染合并规则并生成 PAC；缺失时初始化规则子模块
render_pacproxy_config() {
    git submodule update --init proxy/gfw-pac || {
        error "gfw-pac 子模块初始化失败"
        return 1
    }

    render_pacproxy_assets

    # 渲染 launchd plist（替换 __PYTHON__，并把 ~ 展开为绝对路径避免依赖 launchd 展开）
    sed -e "s|__PYTHON__|$(command -v python3)|g" \
        -e "s|~/.config/pacproxy|$HOME/.config/pacproxy|g" \
        "$REPO_ROOT/proxy/autostart/macos/com.mac.pacproxy.plist" \
        > "$HOME/Library/LaunchAgents/com.mac.pacproxy.plist"
}

# 链接 generated/pacproxy -> ~/.config/pacproxy，并重新加载 launchd 服务
link_pacproxy_config() {
    link_item "$HOME/.config/pacproxy" "$REPO_ROOT/generated/pacproxy"

    # bootout + bootstrap 确保新 plist 参数生效（kickstart -k 不重读配置）
    if launchctl print "gui/$(id -u)/com.mac.pacproxy" >/dev/null 2>&1; then
        step "卸载旧 pacproxy 服务（bootout）"
        launchctl bootout "gui/$(id -u)/com.mac.pacproxy" 2>/dev/null || true
    fi
    step "加载 pacproxy 服务（bootstrap + enable）"
    launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.mac.pacproxy.plist"
    launchctl enable "gui/$(id -u)/com.mac.pacproxy"
}
