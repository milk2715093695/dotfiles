# 交互选择配置冲突处理方式
select_config_action() {
    local answer

    while true; do
        echo "目标已存在，请选择配置处理方式："
        echo "  b/B  备份一次 / 备份并对后续全部生效"
        echo "  r/R  替换一次 / 替换并对后续全部生效"
        echo "  l/L  只替换符号链接，文件或目录备份一次 / 对后续全部生效"
        echo "  s/S  跳过一次 / 跳过并对后续全部生效"
        read -rp "请输入选择 [b/B/r/R/l/L/s/S]: " answer

        case "$answer" in
            b)
                LINK_ACTION="backup"
                return 0
                ;;
            B)
                CONFIG_MODE="backup"
                LINK_ACTION="backup"
                return 0
                ;;
            r)
                LINK_ACTION="replace"
                return 0
                ;;
            R)
                CONFIG_MODE="replace"
                LINK_ACTION="replace"
                return 0
                ;;
            l)
                LINK_ACTION="replace-link"
                return 0
                ;;
            L)
                CONFIG_MODE="replace-link"
                LINK_ACTION="replace-link"
                return 0
                ;;
            s)
                LINK_ACTION="skip"
                return 0
                ;;
            S)
                CONFIG_MODE="skip"
                LINK_ACTION="skip"
                return 0
                ;;
            *)
                echo "请输入 b/B/r/R/l/L/s/S。"
                ;;
        esac
    done
}

# 根据配置解析本次处理方式
resolve_config_action() {
    local mode="${CONFIG_MODE:-ask}"

    case "$mode" in
        ask)
            select_config_action
            ;;
        backup|replace|replace-link|skip)
            LINK_ACTION="$mode"
            ;;
        *)
            warn "未知配置模式 $mode，回退为交互模式。"
            select_config_action
            ;;
    esac
}
