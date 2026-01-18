#!/usr/bin/env bash

set -euo pipefail   # 失败即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本目录
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                   # 仓库目录

# 颜色定义（ANSI）
YELLOW="\033[33m"
RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"

# 交互函数
prompt_confirm() {
    local message="$1"
    local answer

    while true; do
        read -rp "$message [y/n]: " answer
        case "$answer" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# 创建符号链接函数
link_dir() {
    local target_pth="$1"   # 真实路径
    local source_pth="$2"   # 仓库路径

    echo "准备创建链接："
    echo "    目标 (target)：$target_pth -> 源 (source)：$source_pth"
    echo

    if [ -L "$target_pth" ]; then
        echo -e "${YELLOW}注意：目标已经是一个符号链接。将删除旧链接并创建新的链接。${RESET}"

        if prompt_confirm "确认要替换该符号链接吗？"; then
            rm "$target_pth"
            ln -s "$source_pth" "$target_pth"
            echo "已替换符号链接：$target_pth -> $source_pth"
        else
            echo "跳过：$target_pth"
        fi

        return
    fi

    if [ -e "$target_pth" ]; then
        if [ -d "$target_pth" ] && [ -z "$(ls -A "$target_pth")" ]; then
            echo -e "${YELLOW}注意：目标目录存在且为空。将删除该空目录并创建符号链接。${RESET}"

            if prompt_confirm "确认要删除空目录并创建链接吗？"; then
                rmdir "$target_pth"
                ln -s "$source_pth" "$target_pth"
                echo "已创建符号链接：$target_pth -> $source_pth"
            else
                echo "跳过：$target_pth"
            fi
        else
            echo -e "${RED}警告：目标已存在且非空（或不是目录）。${RESET}"
            echo "为避免数据丢失，将不会自动覆盖。"

            if prompt_confirm "确认要强制删除并替换为链接吗？"; then
                rm -rf "$target_pth"
                ln -s "$source_pth" "$target_pth"
                echo "已强制替换：$target_pth -> $source_pth"
            else
                echo "跳过：$target_pth"
            fi
        fi

        return
    fi

    # 目标不存在，可以创建
    if prompt_confirm "即将在 $target_pth 创建符号链接"; then
        mkdir -p "$(dirname "$target_pth")"
        ln -s "$source_pth" "$target_pth"
        echo "已创建符号链接：$target_pth -> $source_pth"
    fi
}

# 安装 JetBrains Mono 字体
install_jetbrains_mono() {
    # 如果已安装，跳过
    if fc-list | grep -i "jetbrains mono" >/dev/null 2>&1; then
        echo "JetBrains Mono 已安装，跳过字体安装。"
        return
    fi

    # 仅支持 Ubuntu/Debian 系
    if command -v apt >/dev/null 2>&1; then
        echo -e "${YELLOW}检测到 apt，准备安装 fonts-jetbrains-mono${RESET}"

        if prompt_confirm "是否使用 apt 安装 JetBrains Mono 字体？"; then
            sudo apt update
            sudo apt install -y fonts-jetbrains-mono
        else
            echo "跳过字体安装。"
        fi
    else
        echo -e "${YELLOW}未检测到 apt，无法自动安装 JetBrains Mono。${RESET}"
        echo "请手动安装字体，或自行扩展脚本。"
    fi
}

# 检查 WezTerm 是否存在
check_wezterm() {
    if command -v wezterm >/dev/null 2>&1; then
        return 0
    fi

    if command -v flatpak >/dev/null 2>&1 && flatpak info org.wezfurlong.wezterm >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

# 使用 flatpak 安装 WezTerm
install_wezterm_via_flatpak() {
    echo -e "${YELLOW}未安装 wezterm，但存在 flatpak。${RESET}"

    if prompt_confirm "是否使用 flatpak 安装 wezterm？"; then
        flatpak install -y flathub org.wezfurlong.wezterm
    else
        echo "跳过 wezterm 安装。"
    fi
}

# 配置 WezTerm 函数
configure_wezterm() {
    # 检查 wezterm 是否存在
    if check_wezterm; then
        echo "wezterm 已存在，跳过安装。"
    else
        if command -v flatpak >/dev/null 2>&1; then
            install_wezterm_via_flatpak
        else
            echo -e "${YELLOW}系统未安装 wezterm，且未检测到 flatpak。${RESET}"
            echo "将跳过 wezterm 配置。"
        fi
    fi

    # 如果已经安装或安装成功，才进行链接
    if check_wezterm; then
        link_dir "$HOME/.config/wezterm" "$REPO_ROOT/wezterm"
    else
        echo -e "${YELLOW}没有 wezterm，跳过 wezterm 配置。${RESET}"
    fi
}

# 入口
main() {
    echo "================================"
    echo " dotfiles deploy (Linux/Ubuntu)"
    echo "================================"
    echo

    install_jetbrains_mono

    configure_wezterm

    echo
    echo -e "${GREEN}部署完成。${RESET}"
}

main
