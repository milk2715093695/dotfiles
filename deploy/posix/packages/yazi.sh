# 检查 Yazi 是否存在
check_yazi() {
    if command -v yazi >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 Yazi
configure_yazi() {
    if check_yazi; then
        skip_msg "Yazi 已存在，跳过安装"
    else
        install_package "$PACKAGE_MANAGER" yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick clipboard glow
    fi

    if check_yazi; then
        link_item "$HOME/.config/yazi" "$REPO_ROOT/yazi"

        # 插件安装属于安装类操作，可由 --yes-install 自动确认
        if prompt_install_confirm "是否安装或更新 yazi 插件？"; then
            # 安装 Yazi 插件和主题
            step "安装或更新 Yazi 插件和主题"
            ya pkg install
        else
            skip_msg "跳过 Yazi 插件和主题安装"
        fi
    else
        warn "没有 Yazi，跳过 Yazi 配置"
    fi
}
