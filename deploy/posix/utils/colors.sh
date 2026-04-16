# ANSI 颜色定义
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[34m"
CYAN="\033[36m"
RESET="\033[0m"

# 判断是否启用颜色输出
supports_color() {
    [ -z "${NO_COLOR:-}" ] && [ -t 1 ]
}

# 输出带标签的消息
print_label() {
    local stream="$1"
    local color="$2"
    local label="$3"
    local message="$4"

    if supports_color; then
        if [ "$stream" = "stderr" ]; then
            printf '%b[%s]%b %s\n' "$color" "$label" "$RESET" "$message" >&2
        else
            printf '%b[%s]%b %s\n' "$color" "$label" "$RESET" "$message"
        fi
        return
    fi

    if [ "$stream" = "stderr" ]; then
        printf '[%s] %s\n' "$label" "$message" >&2
    else
        printf '[%s] %s\n' "$label" "$message"
    fi
}

# 输出普通消息
plain() {
    printf '%s\n' "$1"
}

# 输出 stderr 普通消息
plain_error() {
    printf '%s\n' "$1" >&2
}

# 输出步骤消息
step() {
    print_label stdout "$CYAN" "STEP" "$1"
}

# 输出信息消息
info() {
    print_label stdout "$BLUE" "INFO" "$1"
}

# 输出成功消息
success() {
    print_label stdout "$GREEN" "OK" "$1"
}

# 输出跳过消息
skip_msg() {
    print_label stdout "$YELLOW" "SKIP" "$1"
}

# 输出警告消息
warn() {
    print_label stderr "$YELLOW" "WARN" "$1"
}

# 输出错误消息
error() {
    print_label stderr "$RED" "ERROR" "$1"
}
