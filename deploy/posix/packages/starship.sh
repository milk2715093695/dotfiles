# 检查 Starship 是否存在
check_starship() {
    if command -v starship >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 Starship
configure_starship() {
    if check_starship; then
        skip_msg "Starship 已存在，跳过安装"
    else
        install_package "$PACKAGE_MANAGER" starship
    fi

    if check_starship; then
        link_item "$HOME/.config/starship.toml" "$REPO_ROOT/starship/starship.toml"
    else
        warn "没有 Starship，跳过 Starship 配置"
    fi   
}
