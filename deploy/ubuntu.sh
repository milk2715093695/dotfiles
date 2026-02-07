#!/usr/bin/env bash

set -euo pipefail   # 失败即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本目录
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                   # 仓库目录
PAKAGE_MANAGER="apt"                                        # 包管理器

source "$SCRIPT_DIR/posix/utils/colors.sh"              # 颜色变量
source "$SCRIPT_DIR/posix/utils/prompt.sh"              # 提示函数
source "$SCRIPT_DIR/posix/utils/link.sh"                # 链接函数
source "$SCRIPT_DIR/posix/utils/install_package.sh"     # 安装包函数
source "$SCRIPT_DIR/posix/packages/wezterm.sh"          # WezTerm 安装

source "$SCRIPT_DIR/ubuntu/packages/jetbrains_mono.sh"  # JetBrains Mono 字体安装
source "$SCRIPT_DIR/ubuntu/packages/wezterm.sh"         # WezTerm 安装

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
