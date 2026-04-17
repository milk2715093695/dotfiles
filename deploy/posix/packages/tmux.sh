# 检查 tmux 配置单元是否可用
check_tmux_available() {
    command -v tmux >/dev/null 2>&1
}

# 安装 tmux 配置所需运行时依赖
install_tmux_runtime_dependencies() {
    install_package "$PACKAGE_MANAGER" tmux bash bc coreutils gawk jq
}

# 链接 tmux 配置
link_tmux_config() {
    link_item "$HOME/.config/tmux" "$REPO_ROOT/tmux"
}
