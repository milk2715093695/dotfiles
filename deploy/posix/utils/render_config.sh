# render_config_file — 按需处理 # @platform:<file> 和 # @locals:<file> 标记，将基础配置拼接输出
#
# 本文件提供通用工具函数，由各 render_xxx_config() 按需调用。
# 当基础配置中尚未添加标记时，render 函数不需要调用本工具，
# 直接 cp 即可（快路径）。当基础配置引入标记后，改用本工具处理逐行扫描。
#
# 参数：
#   $1  source        基础配置文件路径
#   $2  output        输出文件路径
#   $3  comment_char  注释符，默认 '#'
#
# 内部推导：
#   tool_dir     = $(dirname "$source")        -- 工具根目录
#   platform_dir = $tool_dir/$DEPLOY_PLATFORM   -- 平台目录（tracked）
#   locals_dir   = $tool_dir/locals             -- 本地覆盖目录（gitignored）
#
# 标记格式：
#   # @platform:<file>.<ext>
#   # @locals:<file>.<ext>
#
# 行为：
#   标记存在 + 对应文件存在   → 标记行被文件内容替换
#   标记存在 + 对应文件不存在 → 标记行被删除（空操作）
render_config_file() {
    local source="$1"
    local output="$2"
    local comment_char="${3:-#}"
    local tool_dir="$(dirname "$source")"
    local platform_dir="$tool_dir/$DEPLOY_PLATFORM"
    local locals_dir="$tool_dir/locals"
    local platform_marker_pattern="^[[:space:]]*${comment_char}[[:space:]]*@platform:"
    local locals_marker_pattern="^[[:space:]]*${comment_char}[[:space:]]*@locals:"
    local platform_marker_regex="^[[:space:]]*${comment_char}[[:space:]]*@platform:(.+)[[:space:]]*$"
    local locals_marker_regex="^[[:space:]]*${comment_char}[[:space:]]*@locals:(.+)[[:space:]]*$"

    if [ ! -f "$source" ]; then
        error "基础配置文件不存在：$source"
        return 1
    fi

    mkdir -p "$(dirname "$output")"

    # 快路径：无标记时直接复制
    if ! grep -q -E "$platform_marker_pattern|$locals_marker_pattern" "$source" 2>/dev/null; then
        cp "$source" "$output"
        return 0
    fi

    # 逐行扫描，处理 @platform: 和 @locals: 标记
    local line

    : > "$output"

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ $platform_marker_regex ]]; then
            local ref_file="${BASH_REMATCH[1]}"
            local full_path="$platform_dir/$ref_file"

            if [ -f "$full_path" ]; then
                cat "$full_path" >> "$output"
            fi
            # 文件不存在：删除标记行（不输出任何内容）
        elif [[ "$line" =~ $locals_marker_regex ]]; then
            local ref_file="${BASH_REMATCH[1]}"
            local full_path="$locals_dir/$ref_file"

            if [ -f "$full_path" ]; then
                cat "$full_path" >> "$output"
            fi
            # 文件不存在：删除标记行（不输出任何内容）
        else
            printf '%s\n' "$line" >> "$output"
        fi
    done < "$source"
}
