# 检查 Cava 配置单元是否可用
check_cava_available() {
    command -v cava >/dev/null 2>&1
}

# 安装 Cava
install_cava() {
    install_package pkg cava mpv pulseaudio
}

# 链接 Cava 配置
link_cava() {
    link_item "$HOME/.config/cava" "$REPO_ROOT/cava/termux"
}
