# 检查 WezTerm 配置单元是否可用（macOS）
check_wezterm_available() {
    if command -v wezterm >/dev/null 2>&1; then
        return 0
    fi

    if command -v brew >/dev/null 2>&1 && brew list --cask wezterm >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

# 使用 Homebrew 安装 WezTerm
install_wezterm() {
    install_package brew cask:wezterm
}
