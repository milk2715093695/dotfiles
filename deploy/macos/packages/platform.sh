# 执行 macOS 平台扩展配置
run_platform_deploy_units() {
    deploy_unit_tags="beauty"
    run_deploy_unit "Aerospace" check_aerospace_available "" install_aerospace_window_stack render_aerospace_window_stack_config link_aerospace_window_stack_config ""
    deploy_unit_tags="beauty"
    run_deploy_unit "SketchyBar" check_sketchybar_available prepare_sketchybar_deps install_sketchybar_package "" link_sketchybar_config ""
    deploy_unit_tags="dev"
    run_deploy_unit "pacproxy" check_pacproxy_available "" "" render_pacproxy_config link_pacproxy_config ""
}
