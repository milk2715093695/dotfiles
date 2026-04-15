#!/usr/bin/env bash

set -euo pipefail   # 失败即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本目录
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                   # 仓库目录
PACKAGE_MANAGER="brew"                                      # 包管理器

source "$SCRIPT_DIR/posix/utils/colors.sh"              # 颜色变量
source "$SCRIPT_DIR/posix/utils/prompt.sh"              # 提示函数
source "$SCRIPT_DIR/posix/utils/link_action.sh"         # 链接策略
source "$SCRIPT_DIR/posix/utils/link.sh"                # 链接函数
source "$SCRIPT_DIR/posix/utils/install_package.sh"     # 安装包函数
source "$SCRIPT_DIR/posix/packages/fonts.sh"            # 安装字体
source "$SCRIPT_DIR/posix/packages/wezterm.sh"          # WezTerm 配置
source "$SCRIPT_DIR/posix/packages/zsh.sh"              # zsh 配置
source "$SCRIPT_DIR/posix/packages/zsh_plugins.sh"      # zsh 插件配置
source "$SCRIPT_DIR/posix/packages/starship.sh"         # starship 安装
source "$SCRIPT_DIR/posix/packages/yazi.sh"             # yazi 安装
source "$SCRIPT_DIR/posix/packages/lazyvim.sh"          # lazyvim 安装
source "$SCRIPT_DIR/posix/packages/tmux.sh"             # tmux 安装

source "$SCRIPT_DIR/macos/packages/wezterm.sh"          # WezTerm 安装
source "$SCRIPT_DIR/macos/packages/cava.sh"             # cava 配置
source "$SCRIPT_DIR/macos/packages/macos.sh"            # macOS 特有配置
source "$SCRIPT_DIR/macos/packages/aerospace.sh"        # Aerospace 配置

source "$SCRIPT_DIR/posix/main.sh"                      # 入口函数

# 解析部署参数并执行入口
parse_deploy_args "$@"

main
