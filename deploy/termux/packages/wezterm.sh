# 检查 WezTerm 配置单元是否可用
check_wezterm_available() {
    return 1
}

# 跳过 Termux 上的 WezTerm 安装
install_wezterm() {
    skip_msg "跳过 WezTerm 安装。"
}
