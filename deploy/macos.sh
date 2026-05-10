#!/usr/bin/env bash

set -euo pipefail   # 失败即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本目录
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                   # 仓库目录
DEPLOY_PLATFORM="macos"                                     # 部署平台
PACKAGE_MANAGER="brew"                                      # 包管理器

source "$SCRIPT_DIR/posix/utils/colors.sh"                      # 颜色变量
source "$SCRIPT_DIR/posix/utils/output_view.sh"                 # 输出视图
source "$SCRIPT_DIR/posix/utils/context.sh"                     # 部署上下文
source "$SCRIPT_DIR/posix/utils/prompt.sh"                      # 提示函数
source "$SCRIPT_DIR/posix/utils/link_action.sh"                 # 链接策略
source "$SCRIPT_DIR/posix/utils/link.sh"                        # 链接函数
source "$SCRIPT_DIR/posix/utils/software_availability.sh"       # 软件可用性检测
source "$SCRIPT_DIR/posix/utils/package_mapping.sh"             # 软件包映射
source "$SCRIPT_DIR/posix/utils/package_manager_selection.sh"   # 包管理器选择
source "$SCRIPT_DIR/posix/utils/install_package.sh"             # 安装包函数
source "$SCRIPT_DIR/posix/utils/deploy_unit.sh"                 # 部署单元生命周期
source "$SCRIPT_DIR/posix/utils/render_config.sh"               # 配置渲染工具
source "$SCRIPT_DIR/posix/utils/tool_check.sh"             # 系统工具预检
source "$SCRIPT_DIR/posix/packages/fonts.sh"                    # 安装字体
source "$SCRIPT_DIR/posix/packages/cli_tools.sh"                # 常用命令行工具
source "$SCRIPT_DIR/posix/packages/wezterm.sh"                  # WezTerm 配置
source "$SCRIPT_DIR/posix/packages/zsh.sh"                      # zsh 配置
source "$SCRIPT_DIR/posix/packages/zsh_plugins.sh"              # zsh 插件配置
source "$SCRIPT_DIR/posix/packages/starship.sh"                 # Starship 安装
source "$SCRIPT_DIR/posix/packages/yazi.sh"                     # Yazi 配置
source "$SCRIPT_DIR/posix/packages/lazyvim.sh"                  # LazyVim 配置
source "$SCRIPT_DIR/posix/packages/tmux.sh"                     # tmux 配置
source "$SCRIPT_DIR/posix/packages/cava.sh"                     # Cava 配置
source "$SCRIPT_DIR/posix/packages/fastfetch.sh"                # fastfetch 配置

source "$SCRIPT_DIR/macos/ensure_brew.sh"           # Homebrew 检测与安装
source "$SCRIPT_DIR/macos/packages/platform.sh"     # macOS 平台扩展配置
source "$SCRIPT_DIR/macos/packages/aerospace.sh"    # Aerospace 窗口管理栈配置

source "$SCRIPT_DIR/posix/main.sh"  # 入口函数

# 解析部署参数并执行入口
parse_deploy_args "$@"
ensure_brew

main
