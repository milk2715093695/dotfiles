# 检查 tmux 是否存在
check_tmux() {
    command -v tmux >/dev/null 2>&1
}

# 安装 tmux
install_tmux() {
    if check_tmux; then
        skip_msg "tmux 已存在，跳过安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" tmux bash bc coreutils gawk jq
}

# 链接 tmux 配置
link_tmux() {
    link_item "$HOME/.config/tmux" "$REPO_ROOT/tmux"
}
