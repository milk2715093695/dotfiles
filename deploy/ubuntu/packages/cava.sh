# 检查 cava 是否存在
check_cava() {
    if command -v cava >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 配置 cava
configure_cava() {
    if check_cava; then
        echo "cava 已存在，跳过安装"
    else
        install_package $PACKAGE_MANAGER cava
    fi

    if check_cava; then
        link_item "$HOME/.config/cava" "$REPO_ROOT/cava/macos"
    else
        warn "没有 cava，跳过 cava 配置"
    fi   
}
