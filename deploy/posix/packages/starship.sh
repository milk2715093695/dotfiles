# 检查 starship 是否存在
check_starship() {
    if command -v starship >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 安装 starship
install_starship() {
    if prompt_confirm "是否使用 brew 安装 starship？"; then
        install_package brew starship false
    else
        echo "跳过 starship 安装。"
    fi
}

# 配置 starship
configure_starship() {
    if check_starship; then
        echo "starship 已存在，跳过安装"
    else
        install_starship
    fi

    if check_starship; then
        link_item "$HOME/.config/starship.toml" "$REPO_ROOT/starship/starship.toml"
    else
        warn "没有 starship，跳过 starship 配置"
    fi   
}
