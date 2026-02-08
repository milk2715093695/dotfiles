# 懒加载 conda 环境
load_conda() {
    if (( $+CONDA_SHLVL )); then
        return
    fi

    source "$HOME/.config/zsh/conda.zsh"
}

# 启动 AVD 的函数
start_avd() {
    # 设置默认 DNS
    local ANDROID_DNS="223.5.5.5,223.6.6.6"

    local avds
    avds=$(emulator -list-avds)

    if [ -z "$avds" ]; then
        echo "未找到任何 AVD，请先创建。"
        return 1
    fi

    echo "可用的 AVD："
    local choices=()
    local i=1
    while IFS= read -r avd; do
        echo "[$i] $avd"
        choices[$i]="$avd"
        ((i++))
    done <<< "$avds"

    echo -n "请输入要启动的编号："
    read -r choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ -n "${choices[$choice]}" ]; then
        local selected="${choices[$choice]}"
        echo "正在启动 AVD: $selected ..."
        emulator -avd "$selected" -dns-server "$ANDROID_DNS" -writable-system -no-snapshot-load -selinux permissive
    else
        echo "无效选择。"
        return 1
    fi
}

# 代理函数
proxy() {
    # 默认参数
    local DEFAULT_IP="127.0.0.1"
    local DEFAULT_HTTP_PORT="9910"
    local DEFAULT_SOCKS5_PORT="9909"

    case "$1" in
        unset)
            # 取消设置
            unset SOCKS5_PROXY HTTP_PROXY HTTPS_PROXY ALL_PROXY
            unset socks5_proxy http_proxy https_proxy all_proxy
            echo "代理环境变量已清空。"
            return 0
            ;;
        set)
            # 使用默认参数设置代理
            local ip="$DEFAULT_IP"
            local http_port="$DEFAULT_HTTP_PORT"
            local socks5_port="$DEFAULT_SOCKS5_PORT"
            ;;
        *)
            echo "请选择操作："
            echo "1) 设置代理"
            echo "2) 取消代理（清空环境变量）"
            read -r choice
            if [[ "$choice" == "2" ]]; then
                proxy unset
                return 0
            fi

            echo "请输入代理 IP（留空默认 ${DEFAULT_IP}）："
            read -r ip
            ip=${ip:-$DEFAULT_IP}

            echo "请输入 HTTP 代理端口（留空默认 ${DEFAULT_HTTP_PORT}）："
            read -r http_port
            http_port=${http_port:-$DEFAULT_HTTP_PORT}

            echo "请输入 SOCKS5 代理端口（留空默认 ${DEFAULT_SOCKS5_PORT}）："
            read -r socks5_port
            socks5_port=${socks5_port:-$DEFAULT_SOCKS5_PORT}
            ;;
    esac

    # 设置代理环境变量（大写）
    export SOCKS5_PROXY="socks5h://${ip}:${socks5_port}"
    export HTTP_PROXY="http://${ip}:${http_port}"
    export HTTPS_PROXY="http://${ip}:${http_port}"
    export ALL_PROXY="socks5h://${ip}:${socks5_port}"

    # 设置代理环境变量（小写）
    export socks5_proxy="$SOCKS5_PROXY"
    export http_proxy="$HTTP_PROXY"
    export https_proxy="$HTTPS_PROXY"
    export all_proxy="$ALL_PROXY"

    # 打印状态
    echo "代理环境变量已设置："
    echo "SOCKS5_PROXY=$SOCKS5_PROXY"
    echo "HTTP_PROXY=$HTTP_PROXY"
    echo "HTTPS_PROXY=$HTTPS_PROXY"
    echo "ALL_PROXY=$ALL_PROXY"
    echo "socks5_proxy=$socks5_proxy"
    echo "http_proxy=$http_proxy"
    echo "https_proxy=$https_proxy"
    echo "all_proxy=$all_proxy"
}

# 懒加载密钥的函数
load_secrets() {
    local secrets_dir="$HOME/.config/zsh/secrets"
    local files=()

    if [[ ! -d "$secrets_dir" ]]; then
        echo "目录 $secrets_dir 不存在"
        return 1
    fi

    setopt local_options null_glob
    files=("$secrets_dir"/*.sh)

    if (( ${#files[@]} == 0 )); then
        echo "没有找到 secrets 文件"
        return 1
    fi

    echo "可用 secrets 文件："
    for i in {1..${#files[@]}}; do
        echo "[$i] $(basename "${files[i]}")"
    done
    echo "[A] 加载全部"

    echo -n "请输入编号或 A："
    read -r choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#files[@]} )); then
        source "${files[choice]}"
        echo "已加载 $(basename "${files[choice]}")"
    elif [[ "$choice" == [Aa] ]]; then
        for f in "${files[@]}"; do
            source "$f"
            echo "已加载 $(basename "$f")"
        done
    else
        echo "无效输入"
        return 1
    fi
}
