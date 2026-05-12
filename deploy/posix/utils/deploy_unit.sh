# 校验可选阶段函数是否存在
validate_deploy_unit_function() {
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
run_deploy_unit_phase() {
    local function_name="$1"

    [ -n "$function_name" ] || return 0
    "$function_name"
}

# 判断部署单元是否可用
deploy_unit_available() {
    local availability_check="$1"

    [ -n "$availability_check" ] || return 0
    "$availability_check"
}

# 校验 manifest 变量是否已显式声明
require_deploy_unit_variable() {
    local variable_name="$1"

    if [ -z "${!variable_name+x}" ]; then
        error "deploy unit manifest 变量未设置：$variable_name"
        return 1
    fi
}

# 执行一个部署单元生命周期
run_deploy_unit() {
    if [ "$#" -ne 7 ]; then
        error "run_deploy_unit 需要 7 个参数：name availability_check prepare install render link update"
        return 1
    fi

    local unit_name="$1"
    local availability_check="$2"
    local prepare_stage="$3"
    local install_stage="$4"
    local render_stage="$5"
    local link_stage="$6"
    local update_stage="$7"

    # 过滤检查：run_platform_deploy_units 等直接调用者通过全局变量传递 tags
    if [ -n "${deploy_unit_tags:-}" ] && ! is_unit_selected "$unit_name" "$deploy_unit_tags"; then
        skip_msg "${unit_name} 被过滤，跳过"
        return 0
    fi

    validate_deploy_unit_function "$unit_name" "availability check" "$availability_check" || return 1
    validate_deploy_unit_function "$unit_name" "依赖准备" "$prepare_stage" || return 1
    validate_deploy_unit_function "$unit_name" "安装" "$install_stage" || return 1
    validate_deploy_unit_function "$unit_name" "渲染" "$render_stage" || return 1
    validate_deploy_unit_function "$unit_name" "链接" "$link_stage" || return 1
    validate_deploy_unit_function "$unit_name" "更新状态" "$update_stage" || return 1

    run_deploy_unit_phase "$prepare_stage" || return 1

    if [ -n "$availability_check" ] && deploy_unit_available "$availability_check"; then
        if [ -n "$install_stage" ]; then
            skip_msg "${unit_name} 已可用，跳过安装"
        fi
    else
        run_deploy_unit_phase "$install_stage" || return 1
    fi

    if [ -n "$availability_check" ] && ! deploy_unit_available "$availability_check"; then
        warn "没有 ${unit_name}，跳过 ${unit_name} 配置"
        DEPLOY_UNIT_SKIPPED=true
        return 0
    fi

    run_deploy_unit_phase "$render_stage" || return 1
    run_deploy_unit_phase "$link_stage" || return 1
    run_deploy_unit_phase "$update_stage" || return 1
}

# 以顶层部署阶段执行一个部署单元生命周期
run_deploy_unit_stage() {
    if [ "$#" -ne 8 ]; then
        error "run_deploy_unit_stage 需要 8 个参数：stage_name name availability_check prepare install render link update"
        return 1
    fi

    local stage_name="$1"
    shift

    run_deploy_stage "$stage_name" run_deploy_unit "$@"
}

# 从 manifest 变量执行一个部署单元生命周期
run_deploy_unit_stage_from_vars() {
    require_deploy_unit_variable deploy_unit_stage_name || return 1
    require_deploy_unit_variable deploy_unit_name || return 1
    require_deploy_unit_variable deploy_unit_availability_check || return 1
    require_deploy_unit_variable deploy_unit_prepare_stage || return 1
    require_deploy_unit_variable deploy_unit_install_stage || return 1
    require_deploy_unit_variable deploy_unit_render_stage || return 1
    require_deploy_unit_variable deploy_unit_link_stage || return 1
    require_deploy_unit_variable deploy_unit_update_stage || return 1
    require_deploy_unit_variable deploy_unit_tags || return 1

    if ! is_unit_selected "$deploy_unit_name" "$deploy_unit_tags"; then
        skip_msg "${deploy_unit_name} 被过滤，跳过"
        return 0
    fi

    run_deploy_unit_stage \
        "$deploy_unit_stage_name" \
        "$deploy_unit_name" \
        "$deploy_unit_availability_check" \
        "$deploy_unit_prepare_stage" \
        "$deploy_unit_install_stage" \
        "$deploy_unit_render_stage" \
        "$deploy_unit_link_stage" \
        "$deploy_unit_update_stage"
}
