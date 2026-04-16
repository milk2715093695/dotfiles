# 安装 JetBrains Mono 字体
install_jetbrains_mono() {
    # 如果已安装，跳过
    if fc-list | grep -i "jetbrains mono" >/dev/null 2>&1; then
        skip_msg "JetBrains Mono 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" cask:font-jetbrains-mono
}

# 安装 Monaspace Nerd Font 字体
install_monospace_nerd_font() {
    if fc-list | grep -i "mona" >/dev/null 2>&1; then
        skip_msg "Monaspace Nerd Font 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" cask:font-monaspace-nerd-font
}

# 安装 Noto Sans Symbols 2 字体
install_noto_sans_symbols_2() {
    if fc-list | grep -i "noto sans symbols 2" >/dev/null 2>&1; then
        skip_msg "Noto Sans Symbols 2 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" "cask:font-noto-sans-symbols-2"
}

# 安装全部字体
install_fonts() {
    install_jetbrains_mono
    install_monospace_nerd_font
    install_noto_sans_symbols_2
}
