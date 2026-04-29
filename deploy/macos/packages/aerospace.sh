# 检查 Aerospace 命令是否可用
check_aerospace_available() {
    check_software_available window.aerospace
}

# 安装 Aerospace 窗口管理栈
install_aerospace_window_stack() {
    if ! command -v brew >/dev/null 2>&1; then
        error "未找到 Homebrew，请先安装 Homebrew。"
        return 1
    fi

    if ! brew tap | grep -Fxq "FelixKratz/formulae"; then
        if prompt_install_confirm "是否添加 Aerospace 相关 Homebrew tap？"; then
            step "添加 Aerospace 相关 Homebrew tap"
            brew tap FelixKratz/formulae
        else
            skip_msg "跳过 Aerospace 相关 Homebrew tap 添加"
            return
        fi
    fi

    install_software_key window.aerospace
}

# 渲染 Aerospace 窗口管理栈配置
render_aerospace_window_stack_config() {
    step "渲染 Aerospace 配置"
    mkdir -p "$REPO_ROOT/generated/aerospace"
    cp "$REPO_ROOT/aerospace/aerospace.toml" "$REPO_ROOT/generated/aerospace/aerospace.toml"
}

# 链接 Aerospace 窗口管理栈配置
link_aerospace_window_stack_config() {
    link_item "$HOME/.config/aerospace" "$REPO_ROOT/generated/aerospace"
    link_item "$HOME/.config/borders" "$REPO_ROOT/borders"
}
