# 配置 zsh 插件
configure_zsh_plugins() {
    install_package "$PACKAGE_MANAGER" zsh-completions

    ZSH_DIR="$HOME/.zsh"
    mkdir -p "$ZSH_DIR"
    cd "$ZSH_DIR" || return

    # 定义插件和仓库地址
    declare -A plugins=(
        [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
        [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    )

    for plugin in "${!plugins[@]}"; do
        repo="${plugins[$plugin]}"
        if [ -d "$plugin/.git" ]; then
            echo "插件 $plugin 已存在，执行 git pull 更新..."
            cd "$plugin" && git pull && cd ..
        else
            echo "插件 $plugin 不存在，执行 git clone..."
            git clone "$repo" "$plugin"
        fi
    done
}
