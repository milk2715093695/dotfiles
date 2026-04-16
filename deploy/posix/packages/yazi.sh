# 检查 Yazi 是否存在
check_yazi() {
    command -v yazi >/dev/null 2>&1
}

# 安装 Yazi
install_yazi() {
    if check_yazi; then
        skip_msg "Yazi 已存在，跳过安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick clipboard glow
}

# 链接 Yazi 配置
link_yazi() {
    link_item "$HOME/.config/yazi" "$REPO_ROOT/yazi"
}

# 更新 Yazi 插件和主题
update_yazi() {
    # 插件安装属于安装类操作，可由 --yes-install 自动确认
    if prompt_install_confirm "是否安装或更新 yazi 插件？"; then
        step "安装或更新 Yazi 插件和主题"
        ya pkg install
    else
        skip_msg "跳过 Yazi 插件和主题安装"
    fi
}
