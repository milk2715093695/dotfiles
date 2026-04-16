# 配置 WezTerm
configure_wezterm() {
    if check_wezterm; then
        skip_msg "WezTerm 已存在，跳过安装。"
    else
        install_wezterm
    fi

    if check_wezterm; then
        link_item "$HOME/.config/wezterm" "$REPO_ROOT/wezterm"
    else
        warn "没有 WezTerm，跳过 WezTerm 配置。"
    fi
}
