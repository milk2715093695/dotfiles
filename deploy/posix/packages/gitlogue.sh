# 检查 gitlogue 是否可用
check_gitlogue_available() {
    check_software_available cli.gitlogue
}

# 安装 gitlogue
install_gitlogue() {
    case "${DEPLOY_PLATFORM:-}" in
        macos)
            install_software_key cli.gitlogue
            ;;
        ubuntu)
            install_software_key cli.gitlogue

            if ! command -v rustup >/dev/null 2>&1; then
                if prompt_install_confirm "是否使用 rustup 安装 Rust 工具链？"; then
                    step "使用 rustup 安装 Rust 工具链"
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                else
                    skip_msg "跳过 Rust 工具链安装，无法继续安装 gitlogue"
                    return 0
                fi
            else
                skip_msg "Rust 工具链已可用。"
            fi

            if prompt_install_confirm "是否使用 cargo 安装 gitlogue？"; then
                step "编译并安装 gitlogue"
                export PATH="$HOME/.cargo/bin:$PATH"
                cargo install gitlogue
                persist_gitlogue_path
            else
                skip_msg "跳过 gitlogue 安装"
            fi
            ;;
        termux)
            install_software_key cli.gitlogue

            if prompt_install_confirm "是否使用 cargo 安装 gitlogue？"; then
                step "编译并安装 gitlogue"
                export PATH="$HOME/.cargo/bin:$PATH"
                cargo install gitlogue
                persist_gitlogue_path
            else
                skip_msg "跳过 gitlogue 安装"
            fi
            ;;
    esac
}

# 尝试将 ~/.cargo/bin 持久化写入 shell 配置
persist_gitlogue_path() {
    if zsh -c "source '$HOME/.config/zsh/functions.zsh' && declare -F persist_path >/dev/null && persist_path '$HOME/.cargo/bin' --local" 2>/dev/null; then
        skip_msg "~/.cargo/bin 已注册到 locals/env.zsh"
    else
        warn "gitlogue 已编译安装，但未持久化到 shell 配置。"
        warn "请手动将以下行添加到 shell 配置中："
        warn '  export PATH="$HOME/.cargo/bin:$PATH"'
    fi
}

# 链接 gitlogue 配置
link_gitlogue_config() {
    link_item "$HOME/.config/gitlogue" "$REPO_ROOT/gitlogue"
}
