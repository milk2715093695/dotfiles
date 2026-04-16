# 检查 Aerospace 是否存在
check_aerospace() {
    if command -v aerospace >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 Aerospace
configure_aerospace() {
    if check_aerospace; then
        skip_msg "Aerospace 已存在，跳过安装"
    else
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
    fi

    if check_aerospace; then
        link_item "$HOME/.config/aerospace" "$REPO_ROOT/aerospace"
        link_item "$HOME/.config/borders" "$REPO_ROOT/borders"
    else
        warn "没有 Aerospace，跳过 Aerospace 配置"
    fi   
}
