# 检查 Cava 配置单元是否可用
check_cava_available() {
    check_software_available audio.cava
}

# 安装 Cava 配置所需运行时依赖
install_cava_runtime_dependencies() {
    install_software_key audio.cava
}

# 渲染 Cava 配置
render_cava_config() {
    step "渲染 Cava 配置"
    mkdir -p "$REPO_ROOT/generated/cava"
    cp "$REPO_ROOT/cava/macos/config" "$REPO_ROOT/generated/cava/config"
    cp -r "$REPO_ROOT/cava/common/themes" "$REPO_ROOT/generated/cava/themes"
    cp -r "$REPO_ROOT/cava/common/shaders" "$REPO_ROOT/generated/cava/shaders"
}

# 链接 Cava 配置
link_cava_config() {
    # Ubuntu 版 Cava 配置尚未调试完成，暂时复用 macOS 配置。
    link_item "$HOME/.config/cava/config"  "$REPO_ROOT/generated/cava/config"
    link_item "$HOME/.config/cava/themes"  "$REPO_ROOT/generated/cava/themes"
    link_item "$HOME/.config/cava/shaders" "$REPO_ROOT/generated/cava/shaders"
}
