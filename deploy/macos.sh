#!/usr/bin/env bash

set -euo pipefail   # 失败即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本目录
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                   # 仓库目录
DEPLOY_PLATFORM="macos"                                     # 部署平台
PACKAGE_MANAGER="brew"                                      # 包管理器

source "$SCRIPT_DIR/posix/bootstrap.sh"                     # 公共引导

source "$SCRIPT_DIR/macos/ensure_brew.sh"           # Homebrew 检测与安装
source "$SCRIPT_DIR/macos/packages/platform.sh"     # macOS 平台扩展配置
source "$SCRIPT_DIR/macos/packages/aerospace.sh"    # Aerospace 窗口管理栈配置

# 解析部署参数并执行入口
parse_deploy_args "$@"
ensure_brew

main
