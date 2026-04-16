# 检查 Aerospace 是否存在
check_aerospace() {
    command -v aerospace >/dev/null 2>&1
}

# 安装 Aerospace
install_aerospace() {
    if check_aerospace; then
        skip_msg "Aerospace 已存在，跳过安装"
        return
    fi

    if ! command -v brew >/dev/null 2>&1; then
        error "未找到 Homebrew，请先安装 Homebrew。"
        return 1
    fi

    if ! brew tap | grep -Fxq "FelixKratz/formulae"; then
        if prompt_install_confirm "是否添加 Aerospace 相关 Homebrew tap？"; then
            step "添加 Aerospace 相关 Homebrew tap"
            brew tap FelixKratz/formulae
        else
            skip_msg "跳过 Aerospace 相关 Homebrew tap 添加"
            return
        fi
    fi

    install_package brew cask:nikitabobko/tap/aerospace borders
}

# 链接 Aerospace 配置
link_aerospace() {
    link_item "$HOME/.config/aerospace" "$REPO_ROOT/aerospace"
    link_item "$HOME/.config/borders" "$REPO_ROOT/borders"
}
