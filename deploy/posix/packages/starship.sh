# 检查 Starship 配置单元是否可用
check_starship_available() {
    check_software_available shell.starship
}

# 安装 Starship
install_starship() {
    install_software_key shell.starship
}

# 渲染 Starship 配置
render_starship_config() {
    step "渲染 Starship 配置"
    mkdir -p "$REPO_ROOT/generated/starship"
    cp "$REPO_ROOT/starship/starship.toml" "$REPO_ROOT/generated/starship/starship.toml"
}

# 链接 Starship 配置
link_starship_config() {
    link_item "$HOME/.config/starship.toml" "$REPO_ROOT/generated/starship/starship.toml"
}
