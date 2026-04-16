# 检查 Cava 是否存在
check_cava() {
    command -v cava >/dev/null 2>&1
}

# 安装 Cava
install_cava() {
    if check_cava; then
        skip_msg "Cava 已存在，跳过安装"
        return
    fi

    install_package pkg cava mpv pulseaudio
}

# 链接 Cava 配置
link_cava() {
    link_item "$HOME/.config/cava" "$REPO_ROOT/cava/termux"
}
