# 校验可选阶段函数是否存在
validate_config_unit_function() {
    local unit_name="$1"
    local stage_name="$2"
    local function_name="$3"

    [ -n "$function_name" ] || return 0

    if ! declare -F "$function_name" >/dev/null 2>&1; then
        error "$unit_name 的 $stage_name 阶段函数不存在：$function_name"
        return 1
    fi
}

# 执行可选阶段
run_config_unit_stage() {
    local function_name="$1"

    [ -n "$function_name" ] || return 0
    "$function_name"
}

# 判断配置单元是否可用
config_unit_available() {
    local availability_check="$1"

    [ -n "$availability_check" ] || return 0
    "$availability_check"
}

# 执行一个配置单元生命周期
run_config_unit() {
    if [ "$#" -ne 6 ]; then
        error "run_config_unit 需要 6 个参数：name availability_check prepare install link update"
        return 1
    fi

    local unit_name="$1"
    local availability_check="$2"
    local prepare_stage="$3"
    local install_stage="$4"
    local link_stage="$5"
    local update_stage="$6"

    validate_config_unit_function "$unit_name" "availability check" "$availability_check" || return 1
    validate_config_unit_function "$unit_name" "依赖准备" "$prepare_stage" || return 1
    validate_config_unit_function "$unit_name" "安装" "$install_stage" || return 1
    validate_config_unit_function "$unit_name" "链接" "$link_stage" || return 1
    validate_config_unit_function "$unit_name" "更新状态" "$update_stage" || return 1

    run_config_unit_stage "$prepare_stage" || return 1

    if [ -n "$availability_check" ] && config_unit_available "$availability_check"; then
        if [ -n "$install_stage" ]; then
            skip_msg "${unit_name} 已可用，跳过安装"
        fi
    else
        run_config_unit_stage "$install_stage" || return 1
    fi

    if [ -n "$availability_check" ] && ! config_unit_available "$availability_check"; then
        warn "没有 ${unit_name}，跳过 ${unit_name} 配置"
        return 0
    fi

    run_config_unit_stage "$link_stage" || return 1
    run_config_unit_stage "$update_stage"
}

# 以顶层部署阶段执行一个配置单元生命周期
run_deploy_config_unit() {
    if [ "$#" -ne 7 ]; then
        error "run_deploy_config_unit 需要 7 个参数：stage_name name availability_check prepare install link update"
        return 1
    fi

    local stage_name="$1"
    shift

    run_deploy_stage "$stage_name" run_config_unit "$@"
}
