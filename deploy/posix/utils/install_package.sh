# 使用 Starship 官方安装脚本安装 Starship
install_starship_with_official_script() {
    if ! command -v curl >/dev/null 2>&1; then
        error "未找到 curl，无法运行 Starship 官方安装脚本。"
        return 1
    fi

    if prompt_install_confirm "是否使用 Starship 官方安装脚本安装 Starship？"; then
        step "使用 Starship 官方安装脚本安装 Starship"
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        skip_msg "跳过 Starship 官方安装脚本"
    fi
}

# 读取当前系统架构对应的 Yazi GNU deb asset 名称
get_yazi_linux_gnu_deb_asset_name() {
    case "$(uname -m)" in
        x86_64 | amd64)
            printf '%s\n' "yazi-x86_64-unknown-linux-gnu.deb"
            ;;
        aarch64 | arm64)
            printf '%s\n' "yazi-aarch64-unknown-linux-gnu.deb"
            ;;
        *)
            return 1
            ;;
    esac
}

# 使用 Yazi 官方 stable deb 安装 Yazi
install_yazi_with_official_deb() {
    local asset_name
    local download_url
    local temp_dir
    local deb_path
    local install_status=0

    asset_name="$(get_yazi_linux_gnu_deb_asset_name)" || {
        error "当前架构不支持 Yazi 官方 GNU deb：$(uname -m)"
        return 1
    }

    if ! command -v curl >/dev/null 2>&1; then
        error "未找到 curl，无法下载 Yazi 官方 deb。"
        return 1
    fi

    if prompt_install_confirm "是否下载并安装 Yazi 官方 stable deb？"; then
        step "下载并安装 Yazi 官方 stable deb"
        temp_dir="$(mktemp -d)" || return 1
        deb_path="$temp_dir/$asset_name"
        download_url="https://github.com/sxyazi/yazi/releases/latest/download/$asset_name"

        if curl -fL "$download_url" -o "$deb_path" && sudo apt install -y "$deb_path"; then
            install_status=0
        else
            install_status=1
        fi

        rm -rf "$temp_dir"
        return "$install_status"
    else
        skip_msg "跳过 Yazi 官方 deb 安装"
    fi
}

# 确保 Debian/Ubuntu 的 fdfind 以 canonical fd 命令名可用
ensure_fd_command_from_fdfind() {
    local fdfind_path
    local fd_link_path="/usr/local/bin/fd"

    if command -v fd >/dev/null 2>&1; then
        skip_msg "fd 命令已可用。"
        return 0
    fi

    fdfind_path="$(command -v fdfind)" || {
        error "未找到 fdfind，无法创建 fd 兼容链接。"
        return 1
    }

    if [ -e "$fd_link_path" ] && [ ! -L "$fd_link_path" ]; then
        error "$fd_link_path 已存在且不是符号链接，无法覆盖。"
        return 1
    fi

    if prompt_install_confirm "是否创建系统级 fd -> fdfind 兼容链接？"; then
        step "创建系统级 fd -> fdfind 兼容链接"
        sudo install -d -m 0755 /usr/local/bin
        sudo ln -sf "$fdfind_path" "$fd_link_path"
    else
        skip_msg "跳过 fd -> fdfind 兼容链接"
    fi
}

# 执行兼容链接类 install spec
run_compat_link_spec() {
    local link_name="$1"

    case "$link_name" in
        fd-fdfind)
            ensure_fd_command_from_fdfind
            ;;
        *)
            warn "未知 compat-link install spec：$link_name"
            return 1
            ;;
    esac
}

# 执行官方安装器类 install spec
run_installer_spec() {
    local installer_name="$1"

    case "$installer_name" in
        starship-official)
            install_starship_with_official_script
            ;;
        yazi-official-deb)
            install_yazi_with_official_deb
            ;;
        *)
            warn "未知 installer install spec：$installer_name"
            return 1
            ;;
    esac
}

# 判断 WezTerm 官方 APT 源是否已配置
check_wezterm_fury_apt_repository_configured() {
    local keyring_path="/usr/share/keyrings/wezterm-fury.gpg"
    local source_path="/etc/apt/sources.list.d/wezterm.list"
    local source_line="deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *"

    [ -f "$keyring_path" ] && [ -f "$source_path" ] && grep -Fxq "$source_line" "$source_path"
}

# 配置 WezTerm 官方 APT 源
configure_wezterm_fury_apt_repository() {
    local source_line="deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *"

    if check_wezterm_fury_apt_repository_configured; then
        skip_msg "WezTerm 官方 APT 源已配置。"
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1; then
        error "未找到 curl，无法下载 WezTerm APT key。"
        return 1
    fi

    if ! command -v gpg >/dev/null 2>&1; then
        error "未找到 gpg，无法配置 WezTerm APT key。"
        return 1
    fi

    if prompt_install_confirm "是否添加 WezTerm 官方 APT 源？"; then
        step "添加 WezTerm 官方 APT 源"
        sudo install -d -m 0755 /usr/share/keyrings
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        printf '%s\n' "$source_line" | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
        sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
        sudo apt update
    else
        skip_msg "跳过 WezTerm 官方 APT 源配置"
    fi
}

# 执行 APT source 类 install spec
configure_apt_repository_spec() {
    local repository_name="$1"

    case "$repository_name" in
        wezterm-fury)
            configure_wezterm_fury_apt_repository
            ;;
        *)
            warn "未知 apt-repo install spec：$repository_name"
            return 1
            ;;
    esac
}

# 拼接安装确认提示
format_install_confirm_message() {
    local manager="$1"
    local package="$2"
    local install_reason="${3:-}"

    if [ -n "$install_reason" ]; then
        printf '是否使用 %s 安装 %s（%s）？\n' "$manager" "$package" "$install_reason"
    else
        printf '是否使用 %s 安装 %s？\n' "$manager" "$package"
    fi
}

# 根据 canonical software key 选择可用 manager 并安装
install_software_key() {
    local software_key="$1"
    local manager
    local install_specs
    local install_spec
    local IFS='
'

    if check_software_available "$software_key"; then
        skip_msg "$software_key 已可用"
        return 0
    fi

    for manager in $(get_package_manager_priority); do
        [ -n "$manager" ] || continue

        if ! check_package_manager_available "$manager"; then
            continue
        fi

        install_specs="$(get_package_install_specs "$software_key" "$manager")" || continue

        step "选择 $manager 安装 $software_key"
        for install_spec in $install_specs; do
            [ -n "$install_spec" ] || continue
            install_package_spec "$manager" "$install_spec" || return 1
        done
        return 0
    done

    warn "没有可用包管理器支持安装 $software_key，请手动安装。"
    return 0
}

# 安装一组 canonical software key
install_software_keys() {
    local software_key

    for software_key in "$@"; do
        install_software_key "$software_key" || return 1
    done
}

# 使用包管理器安装包（支持多个包）
install_package() {
    local manager="$1"
    shift
    local packages=("$@")
    local install_reason="${DEPLOY_INSTALL_REASON:-}"
    local confirm_message

    if [ ${#packages[@]} -eq 0 ]; then
        error "没有指定要安装的包"
        return 1
    fi

    for package in "${packages[@]}"; do
        local is_cask=false

        # 判断 brew cask 包
        if [[ "$package" == cask:* ]]; then
            is_cask=true
            package="${package#cask:}"  # 去掉前缀
        fi

        # 安装类确认统一走 prompt_install_confirm，避免影响配置覆盖提示
        case "$manager" in
            brew)
                if ! command -v brew >/dev/null 2>&1; then
                    error "未找到 Homebrew，请先安装 Homebrew。"
                    return 1
                fi

                if [ "$is_cask" = true ]; then
                    if brew list --cask "$package" >/dev/null 2>&1; then
                        skip_msg "$package 已安装 (cask)。"
                        continue
                    fi

                    confirm_message="$(format_install_confirm_message brew "$package" "$install_reason")"
                    if prompt_install_confirm "$confirm_message"; then
                        step "使用 brew 安装 $package"
                        brew install --cask "$package"
                    else
                        skip_msg "跳过 $package 安装"
                    fi
                else
                    if brew list "$package" >/dev/null 2>&1; then
                        skip_msg "$package 已安装。"
                        continue
                    fi

                    confirm_message="$(format_install_confirm_message brew "$package" "$install_reason")"
                    if prompt_install_confirm "$confirm_message"; then
                        step "使用 brew 安装 $package"
                        brew install "$package"
                    else
                        skip_msg "跳过 $package 安装"
                    fi
                fi
                ;;
            apt)
                if ! command -v apt >/dev/null 2>&1; then
                    error "未找到 apt，请先安装 apt。"
                    return 1
                fi

                if dpkg -s "$package" >/dev/null 2>&1; then
                    skip_msg "$package 已安装。"
                    continue
                fi

                confirm_message="$(format_install_confirm_message apt "$package" "$install_reason")"
                if prompt_install_confirm "$confirm_message"; then
                    step "使用 apt 安装 $package"
                    sudo apt install -y "$package"
                else
                    skip_msg "跳过 $package 安装"
                fi
                ;;
            dnf)
                if ! command -v dnf >/dev/null 2>&1; then
                    error "未找到 dnf，请先安装 dnf。"
                    return 1
                fi

                if rpm -q "$package" >/dev/null 2>&1; then
                    skip_msg "$package 已安装。"
                    continue
                fi

                confirm_message="$(format_install_confirm_message dnf "$package" "$install_reason")"
                if prompt_install_confirm "$confirm_message"; then
                    step "使用 dnf 安装 $package"
                    sudo dnf install -y "$package"
                else
                    skip_msg "跳过 $package 安装"
                fi
                ;;
            pkg)
                if ! command -v pkg >/dev/null 2>&1; then
                    error "未找到 pkg，请先安装 pkg。"
                    return 1
                fi

                if dpkg -s "$package" >/dev/null 2>&1; then
                    skip_msg "$package 已安装。"
                    continue
                fi

                confirm_message="$(format_install_confirm_message pkg "$package" "$install_reason")"
                if prompt_install_confirm "$confirm_message"; then
                    step "使用 pkg 安装 $package"
                    pkg install -y "$package"
                else
                    skip_msg "跳过 $package 安装"
                fi
                ;;
            pacman)
                if ! command -v pacman >/dev/null 2>&1; then
                    error "未找到 pacman，请先安装 pacman。"
                    return 1
                fi

                if pacman -Q "$package" >/dev/null 2>&1; then
                    skip_msg "$package 已安装。"
                    continue
                fi

                confirm_message="$(format_install_confirm_message pacman "$package" "$install_reason")"
                if prompt_install_confirm "$confirm_message"; then
                    step "使用 pacman 安装 $package"
                    sudo pacman -S --needed --noconfirm "$package"
                else
                    skip_msg "跳过 $package 安装"
                fi
                ;;
            flatpak)
                if ! command -v flatpak >/dev/null 2>&1; then
                    error "未找到 Flatpak，请先安装 Flatpak。"
                    return 1
                fi

                if flatpak list --app --columns=application | grep -Fxq "$package"; then
                    skip_msg "$package 已安装。"
                    continue
                fi

                confirm_message="$(format_install_confirm_message Flatpak "$package" "$install_reason")"
                if prompt_install_confirm "$confirm_message"; then
                    step "使用 Flatpak 安装 $package"
                    flatpak install -y flathub "$package"
                else
                    skip_msg "跳过 $package 安装"
                fi
                ;;
            *)
                error "未知包管理器: $manager"
                return 1
                ;;
        esac
    done
}

# 使用指定 manager 安装一条 install spec
install_package_spec() {
    local manager="$1"
    local install_spec="$2"
    local package_kind="${install_spec%%|*}"
    local package_spec="${install_spec#*|}"
    local package_name="${package_spec%%|*}"
    local install_reason=""

    if [ "$package_spec" != "$package_name" ]; then
        install_reason="${package_spec#*|}"
    fi

    case "$package_kind" in
        package)
            DEPLOY_INSTALL_REASON="$install_reason" install_package "$manager" "$package_name"
            ;;
        cask)
            if [ "$manager" != "brew" ]; then
                warn "$manager 不支持 cask 安装 spec：$package_name"
                return 1
            fi

            install_package "$manager" "cask:$package_name"
            ;;
        installer)
            run_installer_spec "$package_name"
            ;;
        apt-repo)
            if [ "$manager" != "apt" ]; then
                warn "$manager 不支持 apt-repo 安装 spec：$package_name"
                return 1
            fi

            configure_apt_repository_spec "$package_name"
            ;;
        compat-link)
            run_compat_link_spec "$package_name"
            ;;
        *)
            warn "未知 install spec 类型：$package_kind"
            return 1
            ;;
    esac
}
