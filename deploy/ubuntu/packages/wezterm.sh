# 检查 WezTerm 配置单元是否可用
check_wezterm_available() {
    check_software_available terminal.wezterm
}

# 使用 flatpak 安装 WezTerm
install_wezterm() {
    install_package flatpak org.wezfurlong.wezterm
}
