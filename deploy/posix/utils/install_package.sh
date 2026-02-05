# 使用包管理器安装包
install_package() {
    local manager="$1"  # 使用的包管理器
    local package="$2"  # 安装的包名
    local is_cask="${3:-false}" # 是否是 cask 安装（仅限 Homebrew）

    echo "使用 $manager 安装 $package"

    case "$manager" in
        brew)
            if ! command -v brew >/dev/null 2>&1; then
                error "未找到 Homebrew，请先安装 Homebrew。"
                return 1
            fi

            if [ "$is_cask" = true ]; then
                if brew list --cask "$package" >/dev/null 2>&1; then
                    info "$package 已安装 (cask)。"
                    return 0
                fi
                brew install --cask "$package"
            else
                if brew list "$package" >/dev/null 2>&1; then
                    info "$package 已安装。"
                    return 0
                fi
                brew install "$package"
            fi
            ;;
        apt)
            if ! command -v apt >/dev/null 2>&1; then
                error "未找到 apt，请先安装 apt。"
                return 1
            fi

            if dpkg -s "$package" >/dev/null 2>&1; then
                info "$package 已安装。"
                return 0
            fi

            sudo apt install -y "$package"
            ;;
        pacman)
            if ! command -v pacman >/dev/null 2>&1; then
                error "未找到 pacman，请先安装 pacman。"
                return 1
            fi

            if pacman -Q "$package" >/dev/null 2>&1; then
                info "$package 已安装。"
                return 0
            fi

            sudo pacman -S --needed --noconfirm "$package"
            ;;
        flatpak)
            if ! command -v flatpak >/dev/null 2>&1; then
                error "未找到 Flatpak，请先安装 Flatpak。"
                return 1
            fi

            if flatpak list --app --columns=application | grep -Fxq "$package"; then
                info "$package 已安装。"
                return 0
            fi

            flatpak install -y flathub "$package"
            ;;
        *)
            error "未知包管理器: $manager"
            return 1
            ;;
    esac
}
