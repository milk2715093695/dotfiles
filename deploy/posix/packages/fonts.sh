# 检查 fontconfig 是否能找到指定字体
check_fontconfig_font_available() {
    local font_name="$1"

    fc-list | grep -i "$font_name" >/dev/null 2>&1
}

# 检查常用字体配置单元是否可用
check_fonts_available() {
    check_fontconfig_font_available "jetbrains mono" \
        && check_fontconfig_font_available "mona" \
        && check_fontconfig_font_available "noto sans symbols 2"
}

# 安装 JetBrains Mono 字体
install_jetbrains_mono() {
    if check_fontconfig_font_available "jetbrains mono"; then
        skip_msg "JetBrains Mono 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" cask:font-jetbrains-mono
}

# 安装 Monaspace Nerd Font 字体
install_monaspace_nerd_font() {
    if check_fontconfig_font_available "mona"; then
        skip_msg "Monaspace Nerd Font 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" cask:font-monaspace-nerd-font
}

# 安装 Noto Sans Symbols 2 字体
install_noto_sans_symbols_2() {
    if check_fontconfig_font_available "noto sans symbols 2"; then
        skip_msg "Noto Sans Symbols 2 已安装"
        return
    fi

    install_package "$PACKAGE_MANAGER" "cask:font-noto-sans-symbols-2"
}

# 安装全部常用字体
install_fonts() {
    install_jetbrains_mono
    install_monaspace_nerd_font
    install_noto_sans_symbols_2
}
