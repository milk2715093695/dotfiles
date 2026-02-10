# 用于增加 PATH 同时防止环境变量重复添加的函数
add_to_path() {
    for dir in "$@"; do
        if [[ -d "$dir" ]]; then
            if [[ ":$PATH:" != *":$dir:"* ]]; then
                export PATH="$dir:$PATH"
                echo "目录 $dir 被添加到 PATH 中"
            fi
        else 
            echo "错误：目录 $dir 不存在"
        fi
    done
}

# 用于增加 FPATH 同时防止环境变量重复添加的函数
add_to_fpath() {
    for dir in "$@"; do
        if [[ -d "$dir" ]]; then
            if [[ ":$FPATH:" != *":$dir:"* ]]; then
                export FPATH="$dir:$FPATH"
                echo "目录 $dir 被添加到 FPATH 中"
            fi
        else 
            echo "错误：目录 $dir 不存在"
        fi
    done
}


# ====================================================
# ===================== PNPM =========================
# ====================================================
export PNPM_HOME="$HOME/Library/pnpm"
add_to_path "$PNPM_HOME"
# 不需要清理 PNPM_HOME


# ====================================================
# =============== homebrew 相关环境变量 ===============
# ====================================================
# Homebrew 镜像配置
export HOMEBREW_PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
export HOMEBREW_API_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/

# 激活 Homebrew
if [ -x /opt/homebrew/bin/brew ]; then
    eval $(/opt/homebrew/bin/brew shellenv zsh)
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)
fi

if command -v brew >/dev/null 2>&1; then
    HOMEBREW="$(brew --prefix)"

    # Homebrew 的可执行文件路径
    add_to_path "$HOMEBREW/bin"

    # llvm 路径
    add_to_path "$HOMEBREW/opt/llvm/bin"

    # terminfo 相关配置
    export TERMINFO="$HOMEBREW/opt/ncurses/share/terminfo"

    unset HOMEBREW
fi


# ====================================================
# ================= Android SDK 路径 =================
# ====================================================
ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"

add_to_path "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
add_to_path "$ANDROID_SDK_ROOT/platform-tools"
add_to_path "$ANDROID_SDK_ROOT/emulator"

unset ANDROID_SDK_ROOT


# ====================================================
# ======================= JAVA =======================
# ====================================================
# 默认使用 Java 17（如果存在）
if command -v /usr/libexec/java_home >/dev/null 2>&1; then
    if JAVA_HOME_17=$(/usr/libexec/java_home -v 17 2>/dev/null); then
        export JAVA_HOME="$JAVA_HOME_17"
        add_to_path "$JAVA_HOME/bin"
    fi
fi
# 不需要清理 JAVA_HOME


# ====================================================
# ======================= 杂项 =======================
# ====================================================

# Rust Cargo 可执行文件路径
add_to_path "$HOME/.cargo/bin"

# 当前用户 bin 目录
add_to_path "$HOME/bin"

# LaTeX 路径
add_to_path "/Library/TeX/texbin"

# 配置 fzf 使用 fd
export FZF_DEFAULT_COMMAND='fd --type f'
