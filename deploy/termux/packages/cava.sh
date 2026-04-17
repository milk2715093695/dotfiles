# 检查 Cava 配置单元是否可用
check_cava_available() {
    check_software_available audio.cava
}

# 安装 Cava 配置所需运行时依赖
install_cava_runtime_dependencies() {
    install_package pkg cava mpv pulseaudio
}

# 链接 Cava 配置
link_cava_config() {
    link_item "$HOME/.config/cava" "$REPO_ROOT/cava/termux"
}
