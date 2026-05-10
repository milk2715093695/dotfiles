# 部署入口
main() {
    init_deploy_output_view
    check_system_tools

    local deploy_unit_stage_name
    local deploy_unit_name
    local deploy_unit_availability_check
    local deploy_unit_prepare_stage
    local deploy_unit_install_stage
    local deploy_unit_render_stage
    local deploy_unit_link_stage
    local deploy_unit_update_stage

    # 每个 unit 显式填满所有槽位，空字符串表示该阶段不存在。
    deploy_unit_stage_name="安装字体"
    deploy_unit_name="Fonts"
    deploy_unit_availability_check="check_fonts_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_fonts"
    deploy_unit_render_stage=""
    deploy_unit_link_stage=""
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="配置 WezTerm"
    deploy_unit_name="WezTerm"
    deploy_unit_availability_check="check_wezterm_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_wezterm"
    deploy_unit_render_stage=""
    deploy_unit_link_stage="link_wezterm_config"
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="安装常用命令行工具"
    deploy_unit_name="CLI Tools"
    deploy_unit_availability_check="check_cli_tools_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_cli_tools"
    deploy_unit_render_stage=""
    deploy_unit_link_stage=""
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="配置 zsh 插件"
    deploy_unit_name="zsh Plugins"
    deploy_unit_availability_check=""
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_zsh_plugins"
    deploy_unit_render_stage=""
    deploy_unit_link_stage=""
    deploy_unit_update_stage="update_zsh_plugins"
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="配置 Starship"
    deploy_unit_name="Starship"
    deploy_unit_availability_check="check_starship_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_starship"
    deploy_unit_render_stage=""
    deploy_unit_link_stage="link_starship_config"
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="配置 zsh"
    deploy_unit_name="zsh"
    deploy_unit_availability_check=""
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage=""
    deploy_unit_render_stage=""
    deploy_unit_link_stage="link_zsh_config"
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="配置 Yazi"
    deploy_unit_name="Yazi"
    deploy_unit_availability_check="check_yazi_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_yazi_runtime_dependencies"
    deploy_unit_render_stage="render_yazi_config"
    deploy_unit_link_stage="link_yazi_config"
    deploy_unit_update_stage="install_or_update_yazi_packages"
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="配置 Cava"
    deploy_unit_name="Cava"
    deploy_unit_availability_check="check_cava_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_cava_runtime_dependencies"
    deploy_unit_render_stage="render_cava_config"
    deploy_unit_link_stage="link_cava_config"
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="配置 LazyVim"
    deploy_unit_name="LazyVim"
    deploy_unit_availability_check="check_lazyvim_runtime_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_lazyvim_runtime_dependencies"
    deploy_unit_render_stage=""
    deploy_unit_link_stage="link_lazyvim_config"
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    deploy_unit_stage_name="配置 tmux"
    deploy_unit_name="tmux"
    deploy_unit_availability_check="check_tmux_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_tmux_runtime_dependencies"
    deploy_unit_render_stage=""
    deploy_unit_link_stage="link_tmux_config"
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    run_deploy_stage "配置平台扩展行为" run_platform_deploy_units

    deploy_unit_stage_name="配置 fastfetch"
    deploy_unit_name="fastfetch"
    deploy_unit_availability_check="check_fastfetch_available"
    deploy_unit_prepare_stage=""
    deploy_unit_install_stage="install_fastfetch"
    deploy_unit_render_stage=""
    deploy_unit_link_stage="link_fastfetch_config"
    deploy_unit_update_stage=""
    run_deploy_unit_stage_from_vars

    success "部署完成"
}
