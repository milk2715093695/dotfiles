# Return install specs for a canonical software key on a package manager.
get_package_install_specs() {
    local software_key="$1"
    local manager="$2"

    case "$manager:$software_key" in
        brew:cli.fd) printf '%s\n' "package|fd" ;;
        brew:cli.fzf) printf '%s\n' "package|fzf" ;;
        brew:cli.zoxide) printf '%s\n' "package|zoxide" ;;
        brew:shell.starship) printf '%s\n' "package|starship" ;;
        brew:shell.fastfetch) printf '%s\n' "package|fastfetch" ;;
        brew:editor.neovim)
            printf '%s\n' \
                "package|neovim" \
                "package|python3" \
                "package|nodejs" \
                "package|fd"
            ;;
        brew:terminal.wezterm)
            [ "${DEPLOY_PLATFORM:-}" = "macos" ] || return 1
            printf '%s\n' "cask|wezterm"
            ;;
        brew:terminal.tmux)
            printf '%s\n' \
                "package|tmux" \
                "package|bash" \
                "package|bc" \
                "package|coreutils" \
                "package|gawk" \
                "package|jq"
            ;;
        brew:filemanager.yazi)
            printf '%s\n' \
                "package|yazi" \
                "package|ffmpeg" \
                "package|7zip" \
                "package|jq" \
                "package|poppler" \
                "package|fd" \
                "package|ripgrep" \
                "package|fzf" \
                "package|zoxide" \
                "package|resvg" \
                "package|imagemagick" \
                "package|clipboard" \
                "package|glow"
            ;;
        brew:audio.cava)
            printf '%s\n' "package|cava"
            if [ "${DEPLOY_PLATFORM:-}" = "macos" ]; then
                printf '%s\n' "cask|blackhole-2ch"
            fi
            ;;
        brew:font.jetbrains-mono)
            [ "${DEPLOY_PLATFORM:-}" = "macos" ] || return 1
            printf '%s\n' "cask|font-jetbrains-mono"
            ;;
        brew:font.monaspace-nerd)
            [ "${DEPLOY_PLATFORM:-}" = "macos" ] || return 1
            printf '%s\n' "cask|font-monaspace-nerd-font"
            ;;
        brew:font.noto-sans-symbols-2)
            [ "${DEPLOY_PLATFORM:-}" = "macos" ] || return 1
            printf '%s\n' "cask|font-noto-sans-symbols-2"
            ;;
        brew:window.aerospace)
            [ "${DEPLOY_PLATFORM:-}" = "macos" ] || return 1
            printf '%s\n' \
                "cask|nikitabobko/tap/aerospace" \
                "package|borders"
            ;;

        apt:cli.fd)
            printf '%s\n' \
                "package|fd-find|fd 文件搜索工具的 Ubuntu 包" \
                "compat-link|fd-fdfind"
            ;;
        apt:cli.fzf) printf '%s\n' "package|fzf" ;;
        apt:cli.zoxide) printf '%s\n' "package|zoxide" ;;
        apt:shell.starship)
            printf '%s\n' \
                "package|curl|Starship 官方安装脚本下载工具" \
                "installer|starship-official"
            ;;
        apt:shell.fastfetch)
            printf '%s\n' \
                "package|software-properties-common|PPA 管理工具" \
                "apt-repo|fastfetch-ppa" \
                "package|fastfetch|fastfetch 系统信息工具"
            ;;
        apt:editor.neovim)
            printf '%s\n' \
                "package|neovim" \
                "package|python3" \
                "package|nodejs"
            ;;
        apt:terminal.wezterm)
            printf '%s\n' \
                "package|curl|WezTerm APT key 下载工具" \
                "package|gpg|WezTerm APT key 处理工具" \
                "package|ca-certificates|WezTerm HTTPS APT 源依赖" \
                "apt-repo|wezterm-fury" \
                "package|wezterm|WezTerm 终端本体"
            ;;
        apt:terminal.tmux)
            printf '%s\n' \
                "package|tmux" \
                "package|bash" \
                "package|bc" \
                "package|coreutils" \
                "package|gawk" \
                "package|jq"
            ;;
        apt:filemanager.yazi)
            printf '%s\n' \
                "package|curl|Yazi 官方 deb 下载工具" \
                "package|file|Yazi 文件类型检测依赖" \
                "package|ffmpeg|Yazi 视频缩略图支持" \
                "package|7zip|Yazi 压缩包预览和解压支持" \
                "package|jq|Yazi JSON 预览支持" \
                "package|poppler-utils|Yazi PDF 预览支持" \
                "package|fd-find|Yazi 文件名搜索依赖" \
                "compat-link|fd-fdfind" \
                "package|ripgrep|Yazi 文件内容搜索支持" \
                "package|fzf|Yazi 快速子目录跳转支持" \
                "package|zoxide|Yazi 历史目录跳转支持" \
                "package|imagemagick|Yazi 图片和字体预览支持" \
                "installer|yazi-official-deb"
            ;;
        apt:audio.cava) printf '%s\n' "package|cava" ;;

        dnf:cli.fd) printf '%s\n' "package|fd-find" ;;
        dnf:cli.fzf) printf '%s\n' "package|fzf" ;;
        dnf:cli.zoxide) printf '%s\n' "package|zoxide" ;;
        dnf:shell.fastfetch) printf '%s\n' "package|fastfetch" ;;
        dnf:editor.neovim)
            printf '%s\n' \
                "package|neovim" \
                "package|python3" \
                "package|nodejs" \
                "package|fd-find"
            ;;
        dnf:terminal.tmux)
            printf '%s\n' \
                "package|tmux" \
                "package|bash" \
                "package|bc" \
                "package|coreutils" \
                "package|gawk" \
                "package|jq"
            ;;

        pacman:cli.fd) printf '%s\n' "package|fd" ;;
        pacman:cli.fzf) printf '%s\n' "package|fzf" ;;
        pacman:cli.zoxide) printf '%s\n' "package|zoxide" ;;
        pacman:shell.starship) printf '%s\n' "package|starship" ;;
        pacman:shell.fastfetch) printf '%s\n' "package|fastfetch" ;;
        pacman:editor.neovim)
            printf '%s\n' \
                "package|neovim" \
                "package|python" \
                "package|nodejs" \
                "package|fd"
            ;;
        pacman:terminal.tmux)
            printf '%s\n' \
                "package|tmux" \
                "package|bash" \
                "package|bc" \
                "package|coreutils" \
                "package|gawk" \
                "package|jq"
            ;;
        pacman:filemanager.yazi)
            printf '%s\n' \
                "package|yazi" \
                "package|ffmpeg" \
                "package|7zip" \
                "package|jq" \
                "package|poppler" \
                "package|fd" \
                "package|ripgrep" \
                "package|fzf" \
                "package|zoxide" \
                "package|resvg" \
                "package|imagemagick" \
                "package|wl-clipboard" \
                "package|glow"
            ;;
        pacman:audio.cava) printf '%s\n' "package|cava" ;;

        pkg:cli.fd) printf '%s\n' "package|fd" ;;
        pkg:cli.fzf) printf '%s\n' "package|fzf" ;;
        pkg:cli.zoxide) printf '%s\n' "package|zoxide" ;;
        pkg:editor.neovim)
            printf '%s\n' \
                "package|neovim" \
                "package|python" \
                "package|nodejs" \
                "package|fd"
            ;;
        pkg:terminal.tmux)
            printf '%s\n' \
                "package|tmux" \
                "package|bash" \
                "package|bc" \
                "package|coreutils" \
                "package|gawk" \
                "package|jq"
            ;;
        pkg:filemanager.yazi)
            printf '%s\n' \
                "package|yazi" \
                "package|ffmpeg" \
                "package|7zip" \
                "package|jq" \
                "package|poppler" \
                "package|fd" \
                "package|ripgrep" \
                "package|fzf" \
                "package|zoxide" \
                "package|resvg" \
                "package|imagemagick" \
                "package|clipboard" \
                "package|glow"
            ;;
        pkg:audio.cava)
            printf '%s\n' \
                "package|cava" \
                "package|mpv" \
                "package|pulseaudio"
            ;;
        pkg:shell.fastfetch) printf '%s\n' "package|fastfetch" ;;

        *) return 1 ;;
    esac
}
