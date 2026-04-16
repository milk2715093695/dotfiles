# 安装 zsh 插件依赖
install_zsh_plugins() {
    install_package "$PACKAGE_MANAGER" zsh-autosuggestions zsh-syntax-highlighting zsh-completions
}

# 默认不执行额外的 zsh 插件更新
update_zsh_plugins() {
    return 0
}
