# 检查 yazi 是否已经安装
check_yazi() {
    if command -v yazi >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 yazi
configure_yazi() {
    if check_yazi; then
        echo "yazi 已经安装"
    else
        install_package $PAKAGE_MANAGER yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
    fi

    if check_yazi; then
        link_item "$HOME/.config/yazi" "$REPO_ROOT/yazi"

        # 安装 yazi 的插件和主题
        ya pkg install
    else
        echo "yazi 未安装，跳过"
    fi
}
