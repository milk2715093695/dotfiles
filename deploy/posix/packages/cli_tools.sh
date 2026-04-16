# 检查常用命令行工具是否已全部安装
check_cli_tools() {
    command -v fd >/dev/null 2>&1 \
        && command -v fzf >/dev/null 2>&1 \
        && command -v zoxide >/dev/null 2>&1
}

# 安装常用命令行工具
install_cli_tools() {
    if check_cli_tools; then
        skip_msg "常用命令行工具已存在，跳过安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" fd fzf zoxide
}
