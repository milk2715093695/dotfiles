# 检查指定字体是否已安装
check_font_installed() {
    local font_name="$1"

    fc-list | grep -i "$font_name" >/dev/null 2>&1
}

# 检查常用字体是否已全部安装
check_fonts() {
    check_font_installed "jetbrains mono" \
        && check_font_installed "mona" \
        && check_font_installed "noto sans symbols 2"
}

# 安装 JetBrains Mono 字体
install_jetbrains_mono() {
    if check_font_installed "jetbrains mono"; then
        skip_msg "JetBrains Mono 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" cask:font-jetbrains-mono
}

# 安装 Monaspace Nerd Font 字体
install_monospace_nerd_font() {
    if check_font_installed "mona"; then
        skip_msg "Monaspace Nerd Font 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" cask:font-monaspace-nerd-font
}

# 安装 Noto Sans Symbols 2 字体
install_noto_sans_symbols_2() {
    if check_font_installed "noto sans symbols 2"; then
        skip_msg "Noto Sans Symbols 2 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" "cask:font-noto-sans-symbols-2"
}

# 安装全部常用字体
install_fonts() {
    install_jetbrains_mono
    install_monospace_nerd_font
    install_noto_sans_symbols_2
}
