# 检查 Cava 是否存在
check_cava() {
    if command -v cava >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 Cava
configure_cava() {
    if check_cava; then
        skip_msg "Cava 已存在，跳过安装"
    else
        install_package "$PACKAGE_MANAGER" cava
    fi

    if check_cava; then
        link_item "$HOME/.config/cava" "$REPO_ROOT/cava/macos"
    else
        warn "没有 Cava，跳过 Cava 配置"
    fi   
}
