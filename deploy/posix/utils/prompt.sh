# 解析部署参数
parse_deploy_args() {
    init_deploy_context

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --yes-install)
                DEPLOY_AUTO_INSTALL=true
                ;;
            --config-mode)
                shift
                if [ "$#" -eq 0 ]; then
                    error "缺少 --config-mode 的值"
                    return 1
                fi
                DEPLOY_CONFIG_MODE="$1"
                ;;
            --config-mode=*)
                DEPLOY_CONFIG_MODE="${1#*=}"
                ;;
            --preset)
                shift
                if [ "$#" -eq 0 ]; then
                    error "缺少 --preset 的值"
                    return 1
                fi
                DEPLOY_PRESET="$1"
                ;;
            --preset=*)
                DEPLOY_PRESET="${1#*=}"
                ;;
            --skip)
                shift
                if [ "$#" -eq 0 ]; then
                    error "缺少 --skip 的值"
                    return 1
                fi
                DEPLOY_SKIP_UNITS="$1"
                ;;
            --skip=*)
                DEPLOY_SKIP_UNITS="${1#*=}"
                ;;
            --only)
                shift
                if [ "$#" -eq 0 ]; then
                    error "缺少 --only 的值"
                    return 1
                fi
                DEPLOY_ONLY_UNITS="$1"
                ;;
            --only=*)
                DEPLOY_ONLY_UNITS="${1#*=}"
                ;;
            -h|--help)
                print_deploy_usage
                exit 0
                ;;
            -y)
                error "不再支持 -y。请使用 --yes-install，并用 --config-mode 控制配置覆盖策略。"
                print_deploy_usage
                return 1
                ;;
            *)
                error "未知参数: $1"
                print_deploy_usage
                return 1
                ;;
        esac
        shift
    done

    # --only 和 --preset 互斥校验
    if [ -n "${DEPLOY_ONLY_UNITS:-}" ] && [ -n "${DEPLOY_PRESET:-}" ]; then
        warn "--only 和 --preset 互斥，--only 生效时 --preset 被忽略"
        DEPLOY_PRESET=""
    fi

    # --preset 值校验
    if [ -n "${DEPLOY_PRESET:-}" ]; then
        local preset
        local preset_list
        preset_list="$(printf '%s' "${DEPLOY_PRESET:-}" | tr ',' ' ')"
        for preset in $preset_list; do
            if ! get_preset_tags "$preset" >/dev/null 2>&1; then
                error "无效的预设名称: $preset（可用: beautification/beauty, development/dev）"
                print_deploy_usage
                return 1
            fi
        done
    fi

    case "$DEPLOY_CONFIG_MODE" in
        ask|backup|replace|replace-link|skip)
            ;;
        *)
            error "无效的配置模式: $DEPLOY_CONFIG_MODE"
            print_deploy_usage
            return 1
            ;;
    esac
}

# 打印部署脚本帮助
print_deploy_usage() {
    cat <<EOF
用法: $0 [--yes-install] [--config-mode MODE] [--preset PRESET] [--skip UNIT,...] [--only UNIT,...]

  --yes-install          自动确认安装或更新类操作
  --config-mode MODE     配置冲突策略，默认 ask
  --preset PRESET        按预设过滤部署单元（beautification/beauty, development/dev）
                         逗号分隔多值，取并集
  --skip UNIT,...        排除指定部署单元（逗号分隔，不区分大小写）
  --only UNIT,...        仅部署指定单元（逗号分隔，不区分大小写；与 --preset 互斥）
  -h, --help             显示帮助信息

配置模式:
  ask           遇到已有目标时询问
  backup        备份已有符号链接、文件或目录后创建新链接
  replace       删除已有符号链接、文件或目录后创建新链接
  replace-link  替换符号链接，备份文件或目录
  skip          遇到已有目标时直接跳过

示例:
  $0 --yes-install --config-mode replace-link
  $0 --preset beauty
  $0 --preset dev --skip Cava
  $0 --only WezTerm,LazyVim
EOF
}

# 通用确认提示
prompt_confirm() {
    local message="$1"

    local answer
    while true; do
        if ! { exec 3</dev/tty; } 2>/dev/null; then
            warn "无法读取交互输入，默认跳过。"
            return 1
        fi

        if ! read -rp "$message [y/n]: " answer <&3; then
            exec 3<&-
            warn "无法读取交互输入，默认跳过。"
            return 1
        fi
        exec 3<&-

        case "$answer" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) warn "请输入 y 或 n." ;;
        esac
    done
}

# 只用于安装或更新类确认
prompt_install_confirm() {
    local message="$1"

    if [ "$(get_deploy_auto_install)" = true ]; then
        info "$message [y/n]: y (自动确认安装)"
        return 0
    fi

    prompt_confirm "$message"
}
