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

# conda 懒加载
conda() {
    unfunction conda
    source "$HOME/.config/zsh/locals/conda.zsh"
    conda "$@"
}

# yazi 自动 cd
y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# 将 add_to_path 调用持久化写入 shell 配置
persist_path() {
	local target_file target_line local_flag=false dir=""

	for arg in "$@"; do
		case "$arg" in
			--local) local_flag=true ;;
			*) dir="$arg" ;;
		esac
	done

	if [[ ! -d "$dir" ]]; then
		echo "persist_path: 目录 $dir 不存在" >&2
		return 1
	fi

	if $local_flag; then
		target_file="$HOME/.config/zsh/locals/env.zsh"
	else
		target_file="$HOME/.config/zsh/env.zsh"
	fi

	target_line="add_to_path \"$dir\""

	if [[ -f "$target_file" ]] && grep -Fxq "$target_line" "$target_file" 2>/dev/null; then
		return 0
	fi

	mkdir -p "$(dirname "$target_file")"
	printf '\n%s\n' "$target_line" >> "$target_file"
	echo "persist_path: $dir → ${target_file##*/}"
}
