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
setopt EXTENDED_HISTORY        # 历史记录时间戳
setopt HIST_IGNORE_ALL_DUPS    # 完全去重（内存）
setopt HIST_SAVE_NO_DUPS       # 去重（写盘时不再写入重复项）
setopt HIST_REDUCE_BLANKS      # 去掉多余空格

# 允许用 $EDITOR 编辑当前命令行
# Ctrl-x Ctrl-e 会打开编辑器编辑当前输入的命令
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line
