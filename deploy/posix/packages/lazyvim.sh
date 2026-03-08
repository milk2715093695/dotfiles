# 检查 nvim 是否存在
check_nvim() {
    if command -v nvim >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 lazyvim
configure_lazyvim() {
    install_package $PACKAGE_MANAGER neovim python3 nodejs fd

    if check_nvim; then
        link_item "$HOME/.config/nvim" "$REPO_ROOT/nvim"
    else
        warn "没有 nvim，跳过 nvim 配置"
    fi
}
