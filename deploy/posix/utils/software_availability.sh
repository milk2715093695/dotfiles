# 读取 canonical software key 对应的命令名
get_software_command_name() {
    local software_key="$1"

    case "$software_key" in
        cli.fd) printf '%s\n' "fd" ;;
        cli.fzf) printf '%s\n' "fzf" ;;
        cli.zoxide) printf '%s\n' "zoxide" ;;
        shell.starship) printf '%s\n' "starship" ;;
        shell.fastfetch) printf '%s\n' "fastfetch" ;;
        editor.neovim) printf '%s\n' "nvim" ;;
        terminal.wezterm) printf '%s\n' "wezterm" ;;
        terminal.tmux) printf '%s\n' "tmux" ;;
        filemanager.yazi) printf '%s\n' "yazi" ;;
        audio.cava) printf '%s\n' "cava" ;;
        window.aerospace) printf '%s\n' "aerospace" ;;
        cli.gitlogue) printf '%s\n' "gitlogue" ;;
        *) return 1 ;;
    esac
}

# 检查 canonical software key 对应的命令是否可用
check_command_software_available() {
    local software_key="$1"
    local command_name

    command_name="$(get_software_command_name "$software_key")" || return 1
    command -v "$command_name" >/dev/null 2>&1
}

# 读取 canonical font key 对应的 fontconfig 检索词
get_fontconfig_font_pattern() {
    local software_key="$1"

    case "$software_key" in
        font.jetbrains-mono) printf '%s\n' "jetbrains mono" ;;
        font.monaspace-nerd) printf '%s\n' "mona" ;;
        font.noto-sans-symbols-2) printf '%s\n' "noto sans symbols 2" ;;
        *) return 1 ;;
    esac
}

# 检查 fontconfig 是否能找到 canonical font key
check_fontconfig_software_available() {
    local software_key="$1"
    local font_pattern

    command -v fc-list >/dev/null 2>&1 || return 1
    font_pattern="$(get_fontconfig_font_pattern "$software_key")" || return 1
    fc-list | grep -i "$font_pattern" >/dev/null 2>&1
}

# 检查 Homebrew cask 记录是否能补充证明软件可用
check_homebrew_cask_software_available() {
    local cask_name="$1"

    command -v brew >/dev/null 2>&1 || return 1
    brew list --cask "$cask_name" >/dev/null 2>&1
}

# 检查 Flatpak app 记录是否能补充证明软件可用
check_flatpak_app_software_available() {
    local app_id="$1"

    command -v flatpak >/dev/null 2>&1 || return 1
    flatpak info "$app_id" >/dev/null 2>&1
}

# 检查 canonical software key 当前是否可用
check_software_available() {
    local software_key="$1"

    case "$software_key" in
        font.*)
            check_fontconfig_software_available "$software_key"
            ;;
        terminal.wezterm)
            check_command_software_available "$software_key" \
                || check_homebrew_cask_software_available "wezterm" \
                || check_flatpak_app_software_available "org.wezfurlong.wezterm"
            ;;
        *)
            check_command_software_available "$software_key"
            ;;
    esac
}

# 检查一组 canonical software key 是否全部可用
check_software_keys_available() {
    local software_key

    for software_key in "$@"; do
        check_software_available "$software_key" || return 1
    done
}
