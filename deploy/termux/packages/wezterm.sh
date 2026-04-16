# 检查 WezTerm 是否存在
check_wezterm() {
    return 1
}

# 跳过 Termux 上的 WezTerm 安装
install_wezterm() {
    skip_msg "跳过 WezTerm 安装。"
}
