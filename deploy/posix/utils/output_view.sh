# 部署输出视图初始化
init_deploy_output_view() {
    DEPLOY_STAGE_SUMMARIES=()
}

# 判断是否启用摘要重绘
deploy_output_view_can_reset() {
    [ -t 1 ] && [ "${TERM:-}" != "dumb" ] && [ -z "${CI:-}" ]
}

# 重绘已完成阶段摘要
redraw_deploy_output_summary() {
    local summary

    if ! deploy_output_view_can_reset; then
        return
    fi

    printf '\033[2J\033[H'
    for summary in "${DEPLOY_STAGE_SUMMARIES[@]}"; do
        info "$summary"
    done
}

# 记录并输出阶段开始摘要
start_deploy_stage() {
    local stage_name="$1"
    local summary="开始$stage_name"

    DEPLOY_STAGE_SUMMARIES+=("$summary")
    info "$summary"
}

# 记录阶段完成摘要，并在成功路径重绘视图
complete_deploy_stage() {
    local stage_name="$1"
    local summary="$stage_name 完成"

    DEPLOY_STAGE_SUMMARIES+=("$summary")
    if deploy_output_view_can_reset; then
        redraw_deploy_output_summary
    else
        info "$summary"
    fi
}

# 执行一个顶层部署阶段
run_deploy_stage() {
    local stage_name="$1"
    shift

    start_deploy_stage "$stage_name"
    "$@"
    local status=$?

    if [ "$status" -ne 0 ]; then
        return "$status"
    fi

    complete_deploy_stage "$stage_name"
}
