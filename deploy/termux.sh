#!/usr/bin/env bash

set -euo pipefail   # 失败即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本目录
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                   # 仓库目录
PACKAGE_MANAGER="pkg"                                        # 包管理器

source "$SCRIPT_DIR/posix/utils/colors.sh"              # 颜色变量
source "$SCRIPT_DIR/posix/utils/prompt.sh"              # 提示函数
source "$SCRIPT_DIR/posix/utils/link.sh"                # 链接函数
source "$SCRIPT_DIR/posix/utils/install_package.sh"     # 安装包函数
source "$SCRIPT_DIR/posix/packages/fonts.sh"            # 安装字体
source "$SCRIPT_DIR/posix/packages/wezterm.sh"          # WezTerm 配置
source "$SCRIPT_DIR/posix/packages/zsh.sh"              # zsh 配置
source "$SCRIPT_DIR/posix/packages/starship.sh"         # starship 安装
source "$SCRIPT_DIR/posix/packages/yazi.sh"             # yazi 安装
source "$SCRIPT_DIR/posix/packages/lazyvim.sh"          # lazyvim 安装
source "$SCRIPT_DIR/posix/packages/tmux.sh"             # tmux 安装

source "$SCRIPT_DIR/termux/packages/wezterm.sh"         # WezTerm 安装（占位）
source "$SCRIPT_DIR/termux/packages/zsh_plugins.sh"     # zsh 插件配置
source "$SCRIPT_DIR/termux/packages/cava.sh"            # cava 配置

source "$SCRIPT_DIR/posix/main.sh"                      # 入口函数

# 处理脚本参数 -y 自动确认
AUTO_CONFIRM=false
while getopts "y" opt; do
    case "$opt" in
        y) AUTO_CONFIRM=true ;;
        *) ;;
    esac
done

main
