# ====================================================
# ==================== 历史相关选项 ====================
# ====================================================

# 历史文件
HISTFILE="$HOME/.zsh_history"

# 历史条目数
HISTSIZE=10000
SAVEHIST=10000

# 行为优化
setopt INC_APPEND_HISTORY      # 命令执行后立即写入
setopt SHARE_HISTORY           # 多终端共享
setopt HIST_IGNORE_ALL_DUPS    # 完全去重
setopt HIST_REDUCE_BLANKS      # 去掉多余空格


# ====================================================
# =================== Homebrew 命令 ===================
# ====================================================
if command -v brew >/dev/null 2>&1; then
    HOMEBREW="$(brew --prefix)"

    add_to_fpath "$HOMEBREW/share/zsh/site-functions"

    unset HOMEBREW
fi
