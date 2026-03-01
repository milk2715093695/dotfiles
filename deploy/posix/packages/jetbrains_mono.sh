# 安装 JetBrains Mono 字体
install_jetbrains_mono() {
    # 如果已安装，跳过
    if fc-list | grep -i "jetbrains mono" >/dev/null 2>&1; then
        info "JetBrains Mono 已安装"
        return
    fi

    install_package "$PAKAGE_MANAGER" cask:font-jetbrains-mono
}
