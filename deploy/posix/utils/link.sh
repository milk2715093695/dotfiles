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
