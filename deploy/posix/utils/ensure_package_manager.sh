# 包管理器预检：确保至少一个受支持的包管理器可用
# Linux 不自动 bootstrap，仅做检测 + 指引 + 中止
check_package_manager() {
    local manager
    local available=()
    local priority=($(get_package_manager_priority))

    for manager in "${priority[@]}"; do
        if check_package_manager_available "$manager"; then
            available+=("$manager")
        fi
    done

    if [ ${#available[@]} -gt 0 ]; then
        return 0
    fi

    error "未检测到可用包管理器。"

    case "$DEPLOY_PLATFORM" in
        ubuntu)
            plain "Ubuntu 部署依赖以下之一作为包管理器："
            plain "  apt（sudo apt update && sudo apt install apt）"
            plain "  dnf"
            plain "  pacman"
            plain "  brew（https://brew.sh）"
            ;;
        *)
            plain "当前平台未检测到可用包管理器，请手动准备环境。"
            ;;
    esac

    plain ""
    plain "准备包管理器后重新运行部署脚本即可。"

    exit 1
}
