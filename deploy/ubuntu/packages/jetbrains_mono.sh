# 安装 JetBrains Mono 字体
install_jetbrains_mono() {
    # 如果已安装，跳过
    if fc-list | grep -i "jetbrains mono" >/dev/null 2>&1; then
        echo "JetBrains Mono 已安装，跳过字体安装。"
        return
    fi

    if prompt_confirm "是否安装 JetBrains Mono 字体？"; then
        if ! command -v apt >/dev/null 2>&1; then
            error "未检测到 apt，无法自动安装 JetBrains Mono 字体。"
            return 1
        fi

        install_package "$PAKAGE_MANAGER" fonts-jetbrains-mono
    else
        echo "跳过字体安装。"
    fi
}
