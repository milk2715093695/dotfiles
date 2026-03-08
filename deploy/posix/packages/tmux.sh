# 检查 tmux 是否已经安装
check_tmux() {
    if command -v tmux >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 tmux
configure_tmux() {
    if check_tmux; then
        echo "tmux 已经安装"
    else
        install_package $PACKAGE_MANAGER tmux bash bc coreutils gawk jq
    fi

    if check_tmux; then
        link_item "$HOME/.config/tmux" "$REPO_ROOT/tmux"
    else
        echo "tmux 未安装，跳过"
    fi
}
