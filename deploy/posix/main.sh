# 部署入口
main() {
    init_deploy_output_view

    # 槽位顺序：部署阶段名、配置单元名、可用性检查、依赖、安装、链接、更新
    run_deploy_config_unit \
        "安装字体" \
        "Fonts" \
        check_fonts \
        "" \
        install_fonts \
        "" \
        ""

    run_deploy_config_unit \
        "配置 WezTerm" \
        "WezTerm" \
        check_wezterm \
        "" \
        install_wezterm \
        link_wezterm \
        ""

    run_deploy_config_unit \
        "安装常用命令行工具" \
        "CLI Tools" \
        check_cli_tools \
        "" \
        install_cli_tools \
        "" \
        ""

    run_deploy_config_unit \
        "配置 zsh 插件" \
        "zsh Plugins" \
        "" \
        "" \
        install_zsh_plugins \
        "" \
        update_zsh_plugins

    run_deploy_config_unit \
        "配置 Starship" \
        "Starship" \
        check_starship \
        "" \
        install_starship \
        link_starship \
        ""

    run_deploy_config_unit \
        "配置 zsh" \
        "zsh" \
        "" \
        "" \
        "" \
        link_zsh \
        ""

    run_deploy_config_unit \
        "配置 Yazi" \
        "Yazi" \
        check_yazi \
        "" \
        install_yazi \
        link_yazi \
        update_yazi

    run_deploy_config_unit \
        "配置 Cava" \
        "Cava" \
        check_cava \
        "" \
        install_cava \
        link_cava \
        ""

    run_deploy_config_unit \
        "配置 LazyVim" \
        "LazyVim" \
        check_nvim \
        "" \
        install_lazyvim \
        link_lazyvim \
        ""

    run_deploy_config_unit \
        "配置 tmux" \
        "tmux" \
        check_tmux \
        "" \
        install_tmux \
        link_tmux \
        ""

    run_deploy_stage "配置平台扩展行为" run_platform_config_units

    success "部署完成"
}
