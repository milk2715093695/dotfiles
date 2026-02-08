# 配置 zsh
configure_zsh() {
    link_item "$HOME/.zshrc" "$REPO_ROOT/zsh/.zshrc"    # 链接入口脚本
    link_item "$HOME/.config/zsh" "$REPO_ROOT/zsh/zsh"  # 链接具体配置
}
