# 检查 Neovim 命令是否可用
check_neovim_command_available() {
    check_software_available editor.neovim
}

# 检查 LazyVim 配置所需运行时是否可用
check_lazyvim_runtime_available() {
    check_neovim_command_available
}

# 安装 LazyVim 配置所需运行时依赖
install_lazyvim_runtime_dependencies() {
    install_package "$PACKAGE_MANAGER" neovim python3 nodejs fd
}

# 链接 LazyVim 配置
link_lazyvim_config() {
    link_item "$HOME/.config/nvim" "$REPO_ROOT/nvim"
}
