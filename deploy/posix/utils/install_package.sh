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

                if prompt_confirm "是否使用 brew 安装 $package？"; then
                    brew install --cask "$package"
                else
                    echo "跳过 $package 安装"
                fi
            else
                if brew list "$package" >/dev/null 2>&1; then
                    info "$package 已安装。"
                    return 0
                fi

                if prompt_confirm "是否使用 brew 安装 $package？"; then
                    brew install "$package"
                else
                    echo "跳过 $package 安装"
                fi
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

            if prompt_confirm "是否使用 apt 安装 $package？"; then
                sudo apt install -y "$package"
            else
                echo "跳过 $package 安装"
            fi
            ;;
        pkg)
            if ! command -v pkg >/dev/null 2>&1; then
                error "未找到 pkg，请先安装 pkg。"
                return 1
            fi

            if dpkg -s "$package" >/dev/null 2>&1; then
                info "$package 已安装。"
                return 0
            fi

            if prompt_confirm "是否使用 pkg 安装 $package？"; then
                pkg install -y "$package"
            else
                echo "跳过 $package 安装"
            fi
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

            if prompt_confirm "是否使用 pacman 安装 $package？"; then
                sudo pacman -S --needed --noconfirm "$package"
            else
                echo "跳过 $package 安装"
            fi
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

            if prompt_confirm "是否使用 Flatpak 安装 $package？"; then
                flatpak install -y flathub "$package"
            else
                echo "跳过 $package 安装"
            fi
            ;;
        *)
            error "未知包管理器: $manager"
            return 1
            ;;
    esac
}
