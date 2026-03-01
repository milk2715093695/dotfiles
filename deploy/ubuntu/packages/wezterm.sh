# 检查 WezTerm 是否存在
check_wezterm() {
    if command -v wezterm >/dev/null 2>&1; then
        return 0
    fi

    if command -v flatpak >/dev/null 2>&1 && flatpak info org.wezfurlong.wezterm >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

# 使用 flatpak 安装 WezTerm
install_wezterm() {
    install_package flatpak org.wezfurlong.wezterm
}
