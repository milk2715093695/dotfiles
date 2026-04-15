# 交互选择配置冲突处理方式
select_config_action() {
    local answer

    while true; do
        printf '%s\n' "目标已存在，请选择配置处理方式：" >&2
        printf '%s\n' "  b/B  备份一次 / 备份并对后续全部生效" >&2
        printf '%s\n' "  r/R  替换一次 / 替换并对后续全部生效" >&2
        printf '%s\n' "  l/L  只替换符号链接，文件或目录备份一次 / 对后续全部生效" >&2
        printf '%s\n' "  s/S  跳过一次 / 跳过并对后续全部生效" >&2
        read -rp "请输入选择 [b/B/r/R/l/L/s/S]: " answer

        case "$answer" in
            b)
                printf '%s\n' "backup"
                return 0
                ;;
            B)
                set_deploy_config_mode "backup"
                printf '%s\n' "backup"
                return 0
                ;;
            r)
                printf '%s\n' "replace"
                return 0
                ;;
            R)
                set_deploy_config_mode "replace"
                printf '%s\n' "replace"
                return 0
                ;;
            l)
                printf '%s\n' "replace-link"
                return 0
                ;;
            L)
                set_deploy_config_mode "replace-link"
                printf '%s\n' "replace-link"
                return 0
                ;;
            s)
                printf '%s\n' "skip"
                return 0
                ;;
            S)
                set_deploy_config_mode "skip"
                printf '%s\n' "skip"
                return 0
                ;;
            *)
                printf '%s\n' "请输入 b/B/r/R/l/L/s/S。" >&2
                ;;
        esac
    done
}

# 根据配置解析本次处理方式
resolve_config_action() {
    local mode

    mode="$(get_deploy_config_mode)"

    case "$mode" in
        ask)
            select_config_action
            ;;
        backup|replace|replace-link|skip)
            printf '%s\n' "$mode"
            ;;
        *)
            warn "未知配置模式 $mode，回退为交互模式。" >&2
            select_config_action
            ;;
    esac
}
