# 部署入口
main() {
    install_fonts                   # 安装字体

    configure_wezterm               # 配置 WezTerm

    install_package "$PACKAGE_MANAGER" fd fzf zoxide   # 安装常用命令行工具

    configure_zsh_plugins           # 配置 zsh 插件

    configure_starship              # 配置 Starship
    
    configure_zsh                   # 配置 zsh

    configure_yazi                  # 配置 Yazi

    configure_cava                  # 配置 Cava

    configure_lazyvim               # 配置 LazyVim

    configure_tmux                  # 配置 tmux

    configure_macos                 # 配置 macOS 特有行为

    success "部署完成"
}
