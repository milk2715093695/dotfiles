# 检查 Neovim 是否存在
check_nvim() {
    command -v nvim >/dev/null 2>&1
}

# 安装 LazyVim 依赖
install_lazyvim() {
    install_package "$PACKAGE_MANAGER" neovim python3 nodejs fd
}

# 链接 LazyVim 配置
link_lazyvim() {
    link_item "$HOME/.config/nvim" "$REPO_ROOT/nvim"
}
