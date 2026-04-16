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
用法: $0 [--yes-install] [--config-mode ask|backup|replace|replace-link|skip]

  --yes-install          自动确认安装或更新类操作
  --config-mode MODE     配置冲突策略，默认 ask
  -h, --help             显示帮助信息

配置模式:
  ask           遇到已有目标时询问
  backup        备份已有符号链接、文件或目录后创建新链接
  replace       删除已有符号链接、文件或目录后创建新链接
  replace-link  替换符号链接，备份文件或目录
  skip          遇到已有目标时直接跳过
EOF
}

# 通用确认提示
prompt_confirm() {
    local message="$1"

    local answer
    while true; do
        read -rp "$message [y/n]: " answer
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
