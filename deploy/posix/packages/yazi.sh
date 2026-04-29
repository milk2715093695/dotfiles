# 检查 Yazi 配置单元是否可用
check_yazi_available() {
    check_software_available filemanager.yazi
}

# 安装 Yazi 配置所需运行时依赖
install_yazi_runtime_dependencies() {
    install_software_key filemanager.yazi
}

# 渲染 Yazi 配置
render_yazi_config() {
    step "渲染 Yazi 配置"
    mkdir -p "$REPO_ROOT/generated/yazi"
    cp "$REPO_ROOT/yazi/yazi.toml" "$REPO_ROOT/generated/yazi/yazi.toml"
    cp "$REPO_ROOT/yazi/keymap.toml" "$REPO_ROOT/generated/yazi/keymap.toml"
    cp "$REPO_ROOT/yazi/theme.toml" "$REPO_ROOT/generated/yazi/theme.toml"
    cp "$REPO_ROOT/yazi/vfs.toml" "$REPO_ROOT/generated/yazi/vfs.toml"
    cp "$REPO_ROOT/yazi/package.toml" "$REPO_ROOT/generated/yazi/package.toml"
    cp "$REPO_ROOT/yazi/init.lua" "$REPO_ROOT/generated/yazi/init.lua"
}

# 链接 Yazi 配置
link_yazi_config() {
    link_item "$HOME/.config/yazi" "$REPO_ROOT/generated/yazi"
}

# 安装或更新 Yazi 插件和主题
install_or_update_yazi_packages() {
    # 插件安装属于安装类操作，可由 --yes-install 自动确认
    if prompt_install_confirm "是否安装或更新 yazi 插件？"; then
        step "安装或更新 Yazi 插件和主题"
        ya pkg install
    else
        skip_msg "跳过 Yazi 插件和主题安装"
    fi
}
