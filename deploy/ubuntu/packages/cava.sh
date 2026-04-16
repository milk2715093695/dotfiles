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

    install_package "$PACKAGE_MANAGER" cava
}

# 链接 Cava 配置
link_cava() {
    # Ubuntu 版 Cava 配置尚未调试完成，暂时复用 macOS 配置。
    link_item "$HOME/.config/cava" "$REPO_ROOT/cava/macos"
}
