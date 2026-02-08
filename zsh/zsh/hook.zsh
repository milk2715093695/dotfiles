autoload -Uz add-zsh-hook

# 激活当前目录下的虚拟环境
activate_venv_if_present() {
    if [[ -d "$PWD/.venv" ]]; then
        if [[ "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
            source "$PWD/.venv/bin/activate"
            echo "已激活虚拟环境: $PWD/.venv"
        fi
    fi
}

# 在进入目录后自动列出文件
ls_on_chpwd() {
    local file_count
    file_count=$(find . -maxdepth 1 -mindepth 1 -not -name '.*' 2>/dev/null | wc -l)
    
    if (( file_count <= 50 )); then
        ls
    fi
}

add-zsh-hook chpwd activate_venv_if_present
add-zsh-hook chpwd ls_on_chpwd
