# 按需使用 sudo 执行链接相关命令
run_link_command() {
    local use_sudo="$1"
    shift

    if [ "$use_sudo" = "true" ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# 判断目标是否已存在
target_exists() {
    local target_pth="$1"
    [ -e "$target_pth" ] || [ -L "$target_pth" ]
}

# 判断目标链接是否已经指向源路径
link_points_to_source() {
    local target_pth="$1"
    local source_pth="$2"
    local link_target
    local target_real
    local source_real

    [ -L "$target_pth" ] || return 1

    link_target="$(readlink "$target_pth")" || return 1
    [ "$link_target" = "$source_pth" ] && return 0

    if command -v realpath >/dev/null 2>&1; then
        target_real="$(realpath "$target_pth" 2>/dev/null || true)"
        source_real="$(realpath "$source_pth" 2>/dev/null || true)"

        if [ -n "$target_real" ] && [ "$target_real" = "$source_real" ]; then
            return 0
        fi
    fi

    return 1
}

# 生成不冲突的备份路径
make_backup_path() {
    local target_pth="$1"
    local timestamp
    local backup_pth
    local index

    timestamp="$(date +%Y%m%d-%H%M%S)"
    backup_pth="$target_pth.bak.$timestamp"
    index=1

    while target_exists "$backup_pth"; do
        backup_pth="$target_pth.bak.$timestamp.$index"
        index=$((index + 1))
    done

    printf '%s\n' "$backup_pth"
}

# 备份已有目标
backup_target() {
    local target_pth="$1"
    local use_sudo="$2"
    local backup_pth

    backup_pth="$(make_backup_path "$target_pth")"
    run_link_command "$use_sudo" mv "$target_pth" "$backup_pth"
    echo "已备份：$target_pth -> $backup_pth"
}

# 删除已有目标
remove_target() {
    local target_pth="$1"
    local use_sudo="$2"

    run_link_command "$use_sudo" rm -rf "$target_pth"
    echo "已删除：$target_pth"
}

# 创建符号链接
create_link() {
    local target_pth="$1"
    local source_pth="$2"
    local use_sudo="$3"

    run_link_command "$use_sudo" mkdir -p "$(dirname "$target_pth")"
    run_link_command "$use_sudo" ln -s "$source_pth" "$target_pth"
    echo "已创建符号链接：$target_pth -> $source_pth"
}

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

# 创建或更新符号链接
link_item() {
    local target_pth="$1"
    local source_pth="$2"
    local use_sudo="${3:-false}"

    # 先处理已正确链接的情况，避免重复删除或备份
    echo "准备创建链接："
    echo "    目标 (target)：$target_pth -> 源 (source)：$source_pth"
    echo

    if link_points_to_source "$target_pth" "$source_pth"; then
        echo "目标已经是指向同一源的符号链接，跳过：$target_pth"
        return
    fi

    if target_exists "$target_pth"; then
        resolve_config_action

        # replace-link 只替换旧链接，普通文件和目录仍保留为备份
        case "$LINK_ACTION" in
            backup)
                backup_target "$target_pth" "$use_sudo"
                create_link "$target_pth" "$source_pth" "$use_sudo"
                ;;
            replace)
                remove_target "$target_pth" "$use_sudo"
                create_link "$target_pth" "$source_pth" "$use_sudo"
                ;;
            replace-link)
                if [ -L "$target_pth" ]; then
                    remove_target "$target_pth" "$use_sudo"
                else
                    backup_target "$target_pth" "$use_sudo"
                fi
                create_link "$target_pth" "$source_pth" "$use_sudo"
                ;;
            skip)
                echo "跳过：$target_pth"
                ;;
        esac
        return
    fi

    create_link "$target_pth" "$source_pth" "$use_sudo"
}
