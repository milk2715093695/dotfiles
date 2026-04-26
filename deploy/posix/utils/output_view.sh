# 部署输出视图初始化
init_deploy_output_view() {
    DEPLOY_STAGE_SUMMARIES=()
    DEPLOY_UNIT_SKIPPED=false
}

# 判断是否启用摘要重绘
deploy_output_view_can_reset() {
    [ -t 1 ] && [ "${TERM:-}" != "dumb" ] && [ -z "${CI:-}" ]
}

# 重绘已完成阶段摘要
redraw_deploy_output_summary() {
    local summary_record
    local summary_level
    local summary_message

    if ! deploy_output_view_can_reset; then
        return
    fi

    printf '\033[2J\033[H'
    for summary_record in "${DEPLOY_STAGE_SUMMARIES[@]}"; do
        summary_level="${summary_record%%|*}"
        summary_message="${summary_record#*|}"

        case "$summary_level" in
            skip) skip_msg "$summary_message" ;;
            *) info "$summary_message" ;;
        esac
    done
}

# 记录并输出阶段开始摘要
start_deploy_stage() {
    local stage_name="$1"
    local summary="开始$stage_name"

    DEPLOY_STAGE_SUMMARIES+=("info|$summary")
    info "$summary"
}

# 记录阶段完成摘要，并在成功路径重绘视图
complete_deploy_stage() {
    local stage_name="$1"
    local summary="$stage_name 完成"

    DEPLOY_STAGE_SUMMARIES+=("info|$summary")
    if deploy_output_view_can_reset; then
        redraw_deploy_output_summary
    else
        info "$summary"
    fi
}

# 记录阶段跳过摘要，并在跳过路径重绘视图
skip_deploy_stage() {
    local stage_name="$1"
    local summary="$stage_name 跳过"

    DEPLOY_STAGE_SUMMARIES+=("skip|$summary")
    if deploy_output_view_can_reset; then
        redraw_deploy_output_summary
    else
        skip_msg "$summary"
    fi
}

# 执行一个顶层部署阶段
run_deploy_stage() {
    local stage_name="$1"
    shift

    start_deploy_stage "$stage_name"
    "$@"
    local status=$?

    if [ "${DEPLOY_UNIT_SKIPPED:-false}" = true ]; then
        skip_deploy_stage "$stage_name"
        DEPLOY_UNIT_SKIPPED=false
        return 0
    fi

    if [ "$status" -ne 0 ]; then
        return "$status"
    fi

    complete_deploy_stage "$stage_name"
}
