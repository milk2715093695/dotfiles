# 检查常用命令行工具配置单元是否可用
check_cli_tools_available() {
    check_software_keys_available cli.fd cli.fzf cli.zoxide
}

# 安装常用命令行工具
install_cli_tools() {
    install_software_keys cli.fd cli.fzf cli.zoxide
}
