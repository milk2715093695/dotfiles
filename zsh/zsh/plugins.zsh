# 指定 zsh 插件目录 
if command -v brew >/dev/null 2>&1; then
    ZSH_PLUGIN_BASE="$(brew --prefix)/share"
else
    ZSH_PLUGIN_BASE="$HOME/.zsh"
fi

# 激活 zsh-completions（命令补全）
if [ -d "${ZSH_PLUGIN_BASE}/zsh-completions" ]; then
    add_to_fpath "${ZSH_PLUGIN_BASE}/zsh-completions"
fi

# 激活 zsh-autosuggestions（命令自动提示）
if [ -f "${ZSH_PLUGIN_BASE}/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "${ZSH_PLUGIN_BASE}/zsh-autosuggestions/zsh-autosuggestions.zsh"

    # zsh-autosuggestions 颜色配置
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan"
fi

# 初始化 Starship（用于终端提示符）
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# zoxide 初始化
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# fzf 初始化
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

# 激活 zsh-syntax-highlighting（语法高亮，需要最后加载）
if [ -f "${ZSH_PLUGIN_BASE}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "${ZSH_PLUGIN_BASE}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # 禁用语法高亮中的下划线样式
    (( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[path]=none
    ZSH_HIGHLIGHT_STYLES[path_prefix]=none
fi

unset ZSH_PLUGIN_BASE
