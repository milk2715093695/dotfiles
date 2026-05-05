# 检查 fastfetch 是否可用
check_fastfetch_available() {
    check_software_available shell.fastfetch
}

# 安装 fastfetch
install_fastfetch() {
    install_software_key shell.fastfetch
}

# 链接 fastfetch 配置
link_fastfetch_config() {
    link_item "$HOME/.config/fastfetch" "$REPO_ROOT/fastfetch"
}
