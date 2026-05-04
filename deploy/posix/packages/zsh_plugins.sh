# 安装 zsh 插件依赖
install_zsh_plugins() {
    case "$DEPLOY_PLATFORM" in
        macos)   install_package "$PACKAGE_MANAGER" zsh-autosuggestions zsh-syntax-highlighting zsh-completions ;;
        linux)   install_package "$PACKAGE_MANAGER" zsh-autosuggestions zsh-syntax-highlighting ;;
        termux)  install_package "$PACKAGE_MANAGER" zsh-completions ;;
    esac
}

# 更新 zsh 插件
update_zsh_plugins() {
    case "$DEPLOY_PLATFORM" in
        termux)
            if ! prompt_install_confirm "是否安装或更新 zsh 插件？"; then
                skip_msg "跳过 zsh 插件安装或更新"
                return
            fi

            local zsh_dir="$HOME/.zsh"
            mkdir -p "$zsh_dir"
            cd "$zsh_dir" || return

            declare -A plugins=(
                [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
                [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
            )

            local plugin
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
            ;;
        *) return 0 ;;
    esac
}