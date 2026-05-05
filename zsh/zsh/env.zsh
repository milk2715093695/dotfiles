# 用于增加 PATH 同时防止环境变量重复添加的函数
add_to_path() {
    for dir in "$@"; do
        if [[ -d "$dir" ]]; then
            if [[ ":$PATH:" != *":$dir:"* ]]; then
                export PATH="$dir:$PATH"
                [[ -o interactive ]] && echo "目录 $dir 被添加到 PATH 中"
            fi
        else
            [[ -o interactive ]] && echo "错误：目录 $dir 不存在"
        fi
    done
}

# 用于增加 FPATH 同时防止环境变量重复添加的函数
add_to_fpath() {
    for dir in "$@"; do
        if [[ -d "$dir" ]]; then
            if [[ ":$FPATH:" != *":$dir:"* ]]; then
                export FPATH="$dir:$FPATH"
                [[ -o interactive ]] && echo "目录 $dir 被添加到 FPATH 中"
            fi
        else
            [[ -o interactive ]] && echo "错误：目录 $dir 不存在"
        fi
    done
}


# ====================================================
# ======================= 杂项 =======================
# ====================================================
# 当前用户 bin 目录
add_to_path "$HOME/bin"

# 默认编辑器为 nvim
export EDITOR=nvim
