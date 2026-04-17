#!/usr/bin/env bash

set -euo pipefail   # 失败即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本目录
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                   # 仓库目录
PACKAGE_MANAGER="brew"                                       # 包管理器

source "$SCRIPT_DIR/posix/utils/colors.sh"              # 颜色变量
source "$SCRIPT_DIR/posix/utils/output_view.sh"         # 输出视图
source "$SCRIPT_DIR/posix/utils/context.sh"             # 部署上下文
source "$SCRIPT_DIR/posix/utils/prompt.sh"              # 提示函数
source "$SCRIPT_DIR/posix/utils/link_action.sh"         # 链接策略
source "$SCRIPT_DIR/posix/utils/link.sh"                # 链接函数
source "$SCRIPT_DIR/posix/utils/install_package.sh"     # 安装包函数
source "$SCRIPT_DIR/posix/utils/deploy_unit.sh"         # 部署单元生命周期
source "$SCRIPT_DIR/posix/packages/fonts.sh"            # 安装字体
source "$SCRIPT_DIR/posix/packages/cli_tools.sh"        # 常用命令行工具
source "$SCRIPT_DIR/posix/packages/wezterm.sh"          # WezTerm 配置
source "$SCRIPT_DIR/posix/packages/zsh.sh"              # zsh 配置
source "$SCRIPT_DIR/posix/packages/zsh_plugins.sh"      # zsh 插件配置
source "$SCRIPT_DIR/posix/packages/starship.sh"         # Starship 安装
source "$SCRIPT_DIR/posix/packages/yazi.sh"             # Yazi 配置
source "$SCRIPT_DIR/posix/packages/lazyvim.sh"          # LazyVim 配置
source "$SCRIPT_DIR/posix/packages/tmux.sh"             # tmux 配置
source "$SCRIPT_DIR/posix/packages/platform.sh"         # 平台扩展配置（占位）

source "$SCRIPT_DIR/ubuntu/packages/wezterm.sh"         # WezTerm 安装
source "$SCRIPT_DIR/ubuntu/packages/cava.sh"            # Cava 配置

source "$SCRIPT_DIR/posix/main.sh"                      # 入口函数

# 解析部署参数并执行入口
parse_deploy_args "$@"

main
