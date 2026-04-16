# 部署入口
main() {
    init_deploy_output_view

    run_deploy_stage "安装字体" install_fonts

    run_deploy_stage "配置 WezTerm" configure_wezterm

    run_deploy_stage "安装常用命令行工具" install_package "$PACKAGE_MANAGER" fd fzf zoxide

    run_deploy_stage "配置 zsh 插件" configure_zsh_plugins

    run_deploy_stage "配置 Starship" configure_starship

    run_deploy_stage "配置 zsh" configure_zsh

    run_deploy_stage "配置 Yazi" configure_yazi

    run_deploy_stage "配置 Cava" configure_cava

    run_deploy_stage "配置 LazyVim" configure_lazyvim

    run_deploy_stage "配置 tmux" configure_tmux

    run_deploy_stage "配置平台扩展行为" configure_platform

    success "部署完成"
}
