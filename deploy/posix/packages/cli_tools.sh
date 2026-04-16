# 检查常用命令行工具配置单元是否可用
check_cli_tools_available() {
    command -v fd >/dev/null 2>&1 \
        && command -v fzf >/dev/null 2>&1 \
        && command -v zoxide >/dev/null 2>&1
}

# 安装常用命令行工具
install_cli_tools() {
    install_package "$PACKAGE_MANAGER" fd fzf zoxide
}
