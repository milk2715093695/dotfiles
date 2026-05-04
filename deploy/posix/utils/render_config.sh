# render_config_file — 按需处理 # @locals:<file> 标记，将基础配置与 locals 拼接输出
#
# 本文件提供通用工具函数，由各 render_xxx_config() 按需调用。
# 当基础配置中尚未添加 @locals: 标记时，render 函数不需要调用本工具，
# 直接 cp 即可（快路径）。当基础配置引入标记后，改用本工具处理逐行扫描。
#
# 参数：
#   $1  source       基础配置文件路径
#   $2  locals_dir   locals 目录路径（可为不存在的目录）
#   $3  output       输出文件路径
#   $4  comment_char 注释符，默认 '#'
#
# 标记格式：
#   # @locals:<file>.<ext>
#
# 行为：
#   标记存在 + locals 文件存在   → 标记行被 locals 文件内容替换
#   标记存在 + locals 文件不存在 → 标记行被删除（空操作）
#   locals 文件存在 + 标记不存在 → 输出 warning
render_config_file() {
    local source="$1"
    local locals_dir="$2"
    local output="$3"
    local comment_char="${4:-#}"
    local marker_regex="^[[:space:]]*${comment_char}[[:space:]]*@locals:(.+)[[:space:]]*$"

    if [ ! -f "$source" ]; then
        error "基础配置文件不存在：$source"
        return 1
    fi

    mkdir -p "$(dirname "$output")"

    # 快路径：无标记时直接复制
    if ! grep -q "^[[:space:]]*${comment_char}[[:space:]]*@locals:" "$source" 2>/dev/null; then
        cp "$source" "$output"
        return 0
    fi

    # 逐行扫描，处理标记
    local referenced=" "
    local line

    : > "$output"

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ $marker_regex ]]; then
            local ref_file="${BASH_REMATCH[1]}"
            local full_path="$locals_dir/$ref_file"

            if [ -f "$full_path" ]; then
                cat "$full_path" >> "$output"
                referenced="${referenced}${ref_file} "
            fi
            # locals 文件不存在：删除标记行（不输出任何内容）
        else
            printf '%s\n' "$line" >> "$output"
        fi
    done < "$source"

    # 检测孤立的 locals 文件（存在但未被任何标记引用）
    if [ -d "$locals_dir" ]; then
        for local_file in "$locals_dir"/*; do
            [ -f "$local_file" ] || continue
            local base="${local_file##*/}"
            case "$referenced" in
                *" $base "*) ;;
                *) warn "locals 文件未被任何 @locals: 标记引用：${locals_dir}/${base}" ;;
            esac
        done
    fi
}
