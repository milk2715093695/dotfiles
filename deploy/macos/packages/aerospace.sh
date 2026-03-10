# 检查 aerospace 是否存在
check_aerospace() {
    if command -v aerospace >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 aerospace
configure_aerospace() {
    if check_aerospace; then
        echo "aerospace 已存在，跳过安装"
    else
        brew tap FelixKratz/formulae
        install_package brew cask:nikitabobko/tap/aerospace borders
    fi

    if check_aerospace; then
        link_item "$HOME/.config/aerospace" "$REPO_ROOT/aerospace"
        link_item "$HOME/.config/borders" "$REPO_ROOT/borders"
    else
        warn "没有 aerospace，跳过 aerospace 配置"
    fi   
}
