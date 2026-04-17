# 检查 Yazi 配置单元是否可用
check_yazi_available() {
    command -v yazi >/dev/null 2>&1
}

# 安装 Yazi 配置所需运行时依赖
install_yazi_runtime_dependencies() {
    install_package "$PACKAGE_MANAGER" yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick clipboard glow
}

# 链接 Yazi 配置
link_yazi_config() {
    link_item "$HOME/.config/yazi" "$REPO_ROOT/yazi"
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
