# 安装 JetBrains Mono 字体
install_jetbrains_mono() {
    # 如果已安装，跳过
    if fc-list | grep -i "jetbrains mono" >/dev/null 2>&1; then
        echo "JetBrains Mono 已安装，跳过字体安装。"
        return
    fi

    if prompt_confirm "是否安装 JetBrains Mono 字体？"; then
        if ! command -v brew >/dev/null 2>&1; then
            error "未找到 Homebrew，请先安装 Homebrew。"
            return 1
        fi

        brew tap homebrew/cask-fonts    # 订阅字体仓库
        install_package "$PAKAGE_MANAGER" "font-jetbrains-mono" true
    else
        echo "跳过字体安装。"
    fi
}
