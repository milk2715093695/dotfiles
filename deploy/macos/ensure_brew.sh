ensure_brew() {
    if command -v brew >/dev/null 2>&1; then
        if prompt_install_confirm "Homebrew 已安装，是否执行 brew update 更新索引？"; then
            step "更新 Homebrew"
            brew update
        else
            skip_msg "跳过 Homebrew 更新"
        fi
        return 0
    fi

    warn "未检测到 Homebrew，macOS 部署依赖 Homebrew 作为包管理器。"

    if ! prompt_install_confirm "是否安装 Homebrew？"; then
        error "Homebrew 未安装，部署中止。请手动安装：https://brew.sh"
        exit 1
    fi

    step "安装 Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if command -v brew >/dev/null 2>&1; then
        success "Homebrew 安装成功"
    else
        error "Homebrew 安装后仍不可用，请检查：https://brew.sh"
        exit 1
    fi
}
