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

# OpenClaw 补全
# 让 openclaw 命令支持 Tab 补全
if [ -f "$HOME/.openclaw/completions/openclaw.zsh" ]; then
    source "$HOME/.openclaw/completions/openclaw.zsh"
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
    if command -v brew >/dev/null 2>&1; then
        add_to_path "$(brew --prefix)/opt/fzf/bin"
    fi

    source <(fzf --zsh)

    # 配置 fzf 使用 fd
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f'
    fi
fi

# 激活 zsh-syntax-highlighting（语法高亮，需要最后加载）
if [ -f "${ZSH_PLUGIN_BASE}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "${ZSH_PLUGIN_BASE}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # 设置启用的 highlighters
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor)

    (( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES

    source "$MY_ZSH_CONFIG/themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh"
fi

unset ZSH_PLUGIN_BASE
