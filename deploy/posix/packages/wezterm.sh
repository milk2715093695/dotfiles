# 配置 WezTerm
configure_wezterm() {
    if check_wezterm; then
        echo "wezterm 已存在，跳过安装。"
    else
        install_wezterm
    fi

    if check_wezterm; then
        link_dir "$HOME/.config/wezterm" "$REPO_ROOT/wezterm"
    else
        warn "没有 wezterm，跳过 wezterm 配置。"
    fi
}
