# 配置 zsh 插件
configure_zsh_plugins() {
    install_package "$PACKAGE_MANAGER" zsh-completions

    if ! prompt_install_confirm "是否安装或更新 zsh 插件？"; then
        skip_msg "跳过 zsh 插件安装或更新"
        return
    fi

    local zsh_dir="$HOME/.zsh"
    local plugin
    mkdir -p "$zsh_dir"
    cd "$zsh_dir" || return

    # 定义插件和仓库地址
    declare -A plugins=(
        [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
        [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    )

    for plugin in "${!plugins[@]}"; do
        local repo="${plugins[$plugin]}"
        if [ -d "$plugin/.git" ]; then
            step "更新 zsh 插件：$plugin"
            cd "$plugin" && git pull && cd ..
        else
            step "克隆 zsh 插件：$plugin"
            git clone "$repo" "$plugin"
        fi
    done
}
