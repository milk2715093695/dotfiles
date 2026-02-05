# ANSI 颜色定义
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info() {
    echo -e "${GREEN}$1${RESET}"
}

warn(){
    echo -e "${YELLOW}$1${RESET}"
}

error(){
    echo -e "${RED}$1${RESET}"
}
