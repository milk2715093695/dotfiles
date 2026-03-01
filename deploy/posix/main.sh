# 入口
main() {
    install_jetbrains_mono          # 安装 JetBrains Mono 字体

    configure_wezterm               # 配置 wezterm

    install_package $PAKAGE_MANAGER fd fzf zoxide   # 安装 fd

    configure_zsh_plugins           # 配置 zsh 插件

    configure_starship              # 配置 starship
    
    configure_zsh           # 配置 zsh

    configure_yazi          # 配置 yazi

    info "部署完成"
}
