# 执行 macOS 平台扩展配置
run_platform_deploy_units() {
    run_deploy_unit "Aerospace" check_aerospace_available "" install_aerospace_window_stack link_aerospace_window_stack_config ""
}
