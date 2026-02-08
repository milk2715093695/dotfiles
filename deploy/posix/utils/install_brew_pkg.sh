# 通用 brew 包安装与配置函数
install_brew_pkg() {
    local package="$1"
    local cask="${2:-false}"   # 可选参数，默认 false

    # 检查是否已安装
    if command -v "$package" > /dev/null 2>&1; then
        info "$package 已安装"
        return 0
    fi

    if command -v brew > /dev/null 2>&1 && brew list --formula "$package" > /dev/null 2>&1; then
        info "$package 已安装"
        return 0
    fi

    # 提示安装
    if prompt_confirm "是否使用 brew 安装 $package？"; then
        install_package brew "$package" "$cask"
    else
        echo "跳过 $package 安装"
    fi
}
