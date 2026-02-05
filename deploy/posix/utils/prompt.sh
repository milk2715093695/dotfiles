# 询问用户要进行的操作
prompt_confirm() {
    local message="$1"

    # 如果 AUTO_CONFIRM=true，则自动确认
    if [ "$AUTO_CONFIRM" = true ]; then
        echo "$message [y/n]: y (自动确认)"
        return 0
    fi

    local answer
    while true; do
        read -rp "$message [y/n]: " answer
        case "$answer" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "请输入 y 或 n." ;;
        esac
    done
}
