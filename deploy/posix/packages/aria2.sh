# aria2 下载器配置单元（posix 通用）

# 检查 aria2 是否可用
check_aria2_available() {
    check_software_available cli.aria2
}

# 安装 aria2
install_aria2() {
    install_software_key cli.aria2
}

# 渲染 aria2 配置：处理 @locals 覆盖（下载目录等）
render_aria2_config() {
    step "渲染 aria2 配置"
    mkdir -p "$REPO_ROOT/generated/aria2"

    # rpc-secret 缺失时不写入（保持模板删标记行为），仅提示
    if [ ! -f "$REPO_ROOT/aria2/locals/rpc-secret.conf" ]; then
        warn "aria2 RPC secret 未配置（aria2/locals/rpc-secret.conf 缺失）"
        warn "RPC 将无 token 运行；如需保护请创建该文件（内容形如 rpc-secret=<值>）"
    fi

    # session 目录预创建（aria2 不自动建父目录，首次启动需存在；放 render 保证每次执行）
    mkdir -p "$HOME/.local/state/aria2"
    touch "$HOME/.local/state/aria2/aria2.session"

    render_config_file "$REPO_ROOT/aria2/aria2.conf" "$REPO_ROOT/generated/aria2/aria2.conf"

    # 下载目录预创建（aria2 不自动建父目录）：取渲染产物最后一个 dir= 行展开 ${HOME}
    local download_dir
    download_dir="$(grep '^dir=' "$REPO_ROOT/generated/aria2/aria2.conf" | tail -n 1 | cut -d= -f2- | sed "s|\${HOME}|$HOME|g")"
    if [ -n "$download_dir" ]; then
        mkdir -p "$download_dir"
    fi
}

# 链接 aria2 配置（整目录链接，与 fastfetch/gitlogue 等惯例一致），并注册开机自启（autostart 通用层）
link_aria2_config() {
    link_item "$HOME/.config/aria2" "$REPO_ROOT/generated/aria2"

    register_autostart aria2 \
        "s|__ARIA2__|$(command -v aria2c)|g" \
        "s|~/.config/aria2|$HOME/.config/aria2|g"
}
