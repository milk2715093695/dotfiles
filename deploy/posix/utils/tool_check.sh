# 系统工具预检：在部署开始前检查必需系统命令是否可用

# 检查 curl 和 wget 是否至少有一个可用
_has_http_client() {
    command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1
}

# 系统工具预检
# macOS: git, tar（curl 系统内置）
# Ubuntu: git, curl, tar, sudo
# Termux: git, curl, tar（无 sudo）
check_system_tools() {
    local missing=()

    if ! command -v git >/dev/null 2>&1; then
        missing+=("git")
    fi

    if ! _has_http_client; then
        missing+=("curl 或 wget")
    fi

    if ! command -v tar >/dev/null 2>&1; then
        missing+=("tar")
    fi

    case "$DEPLOY_PLATFORM" in
        ubuntu)
            if ! command -v sudo >/dev/null 2>&1; then
                missing+=("sudo")
            fi
            ;;
    esac

    if [ ${#missing[@]} -eq 0 ]; then
        return 0
    fi

    error "部署所需系统工具缺失: ${missing[*]}"

    case "$DEPLOY_PLATFORM" in
        macos)
            plain "macOS 安装方法:"
            for tool in "${missing[@]}"; do
                case "$tool" in
                    git)
                        plain "  git: xcode-select --install（安装 Xcode 命令行工具）";;
                    tar)
                        plain "  tar: macOS 系统内置，请检查系统完整性";;
                    "curl 或 wget")
                        plain "  curl: macOS 系统内置，请检查系统完整性";;
                esac
            done
            ;;
        ubuntu)
            plain "Ubuntu 安装方法:"
            for tool in "${missing[@]}"; do
                case "$tool" in
                    git)    plain "  sudo apt install git" ;;
                    tar)    plain "  sudo apt install tar" ;;
                    sudo)   plain "  sudo 为系统级工具，请以 root 身份安装：apt install sudo" ;;
                    "curl 或 wget") plain "  sudo apt install curl" ;;
                esac
            done
            ;;
        termux)
            plain "Termux 安装方法:"
            for tool in "${missing[@]}"; do
                case "$tool" in
                    git)    plain "  pkg install git" ;;
                    tar)    plain "  pkg install tar" ;;
                    "curl 或 wget") plain "  pkg install curl" ;;
                esac
            done
            ;;
    esac

    plain ""
    plain "安装后重新运行部署脚本即可。"

    exit 1
}
