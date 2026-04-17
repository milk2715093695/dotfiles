# 检查 Cava 配置单元是否可用
check_cava_available() {
    command -v cava >/dev/null 2>&1
}

# 安装 Cava 配置所需运行时依赖
install_cava_runtime_dependencies() {
    install_package "$PACKAGE_MANAGER" cava
}

# 链接 Cava 配置
link_cava_config() {
    # Ubuntu 版 Cava 配置尚未调试完成，暂时复用 macOS 配置。
    link_item "$HOME/.config/cava" "$REPO_ROOT/cava/macos"
}
