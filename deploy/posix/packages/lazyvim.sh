# 检查 Neovim 运行时是否可用
check_nvim_available() {
    command -v nvim >/dev/null 2>&1
}

# 检查 LazyVim 配置单元是否可用
check_lazyvim_available() {
    check_nvim_available
}

# 安装 LazyVim 依赖
install_lazyvim() {
    install_package "$PACKAGE_MANAGER" neovim python3 nodejs fd
}

# 链接 LazyVim 配置
link_lazyvim() {
    link_item "$HOME/.config/nvim" "$REPO_ROOT/nvim"
}
