# 检查 Starship 是否存在
check_starship() {
    command -v starship >/dev/null 2>&1
}

# 安装 Starship
install_starship() {
    if check_starship; then
        skip_msg "Starship 已存在，跳过安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" starship
}

# 链接 Starship 配置
link_starship() {
    link_item "$HOME/.config/starship.toml" "$REPO_ROOT/starship/starship.toml"
}
