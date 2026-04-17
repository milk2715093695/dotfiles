# 检查 Starship 配置单元是否可用
check_starship_available() {
    check_software_available shell.starship
}

# 安装 Starship
install_starship() {
    install_package "$PACKAGE_MANAGER" starship
}

# 链接 Starship 配置
link_starship_config() {
    link_item "$HOME/.config/starship.toml" "$REPO_ROOT/starship/starship.toml"
}
