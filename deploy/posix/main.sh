# 入口
main() {
    install_jetbrains_mono          # 安装 JetBrains Mono 字体

    configure_wezterm               # 配置 wezterm

    install_brew_pkg fd false       # 安装 fd

    configure_zsh_plugins           # 配置 zsh 插件

    configure_starship              # 配置 starship

    install_brew_pkg fzf false      # 安装 fzf

    install_brew_pkg zoxide false   # 安装 zoxide
    
    configure_zsh           # 配置 zsh

    info "部署完成"
}
