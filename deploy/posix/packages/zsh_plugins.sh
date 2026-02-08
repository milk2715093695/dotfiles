# 配置 zsh 插件
configure_zsh_plugins() {
    if prompt_confirm "是否安装 zsh-autosuggestions、zsh-syntax-highlighting、zsh-completions 插件？"; then
        install_package brew zsh-autosuggestions false
        install_package brew zsh-syntax-highlighting false
        install_package brew zsh-completions false
    fi
}
