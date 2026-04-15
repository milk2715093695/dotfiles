# 初始化部署配置
init_deploy_context() {
    DEPLOY_AUTO_INSTALL=false
    DEPLOY_CONFIG_MODE="ask"
}

# 读取自动安装开关
get_deploy_auto_install() {
    printf '%s\n' "${DEPLOY_AUTO_INSTALL:-false}"
}

# 读取配置冲突模式
get_deploy_config_mode() {
    printf '%s\n' "${DEPLOY_CONFIG_MODE:-ask}"
}

# 更新配置冲突模式
set_deploy_config_mode() {
    local config_mode="$1"
    DEPLOY_CONFIG_MODE="$config_mode"
}
