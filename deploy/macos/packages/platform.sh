# 执行 macOS 平台扩展配置
run_platform_deploy_units() {
    deploy_unit_tags="beauty"
    run_deploy_unit "Aerospace" check_aerospace_available "" install_aerospace_window_stack render_aerospace_window_stack_config link_aerospace_window_stack_config ""
    deploy_unit_tags="beauty"
    run_deploy_unit "SketchyBar" check_sketchybar_available "" install_sketchybar_package "" link_sketchybar_config ""
}
