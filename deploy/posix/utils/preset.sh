# 预设定义：预设名 → 标签集合
# beautification: 看得到的 — 字体/终端/prompt/窗口管理/文件管理器/编辑器
# development:   用得着的 — CLI 工具/zsh 配置/插件/编辑器/文件管理器
PRESET_BEAUTY_TAGS="beauty"
PRESET_DEV_TAGS="dev"

# 将预设名（全名或短名，不区分大小写）映射为标签列表
get_preset_tags() {
    local preset_name
    preset_name="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"

    case "$preset_name" in
        beautification|beauty) printf '%s\n' "$PRESET_BEAUTY_TAGS" ;;
        development|dev)       printf '%s\n' "$PRESET_DEV_TAGS" ;;
        *)                     return 1 ;;
    esac
}

# 根据当前过滤设置（--only / --skip / --preset）判断 unit 是否被选中
is_unit_selected() {
    local unit_name="$1"
    local unit_tags="$2"

    # --only: 仅部署指定 unit，忽略预设和 --skip
    if [ -n "${DEPLOY_ONLY_UNITS:-}" ]; then
        if list_contains "$unit_name" "${DEPLOY_ONLY_UNITS:-}"; then
            return 0
        fi
        DEPLOY_UNIT_SKIPPED=true
        return 1
    fi

    # --skip: 排除指定 unit
    if [ -n "${DEPLOY_SKIP_UNITS:-}" ] && list_contains "$unit_name" "${DEPLOY_SKIP_UNITS:-}"; then
        DEPLOY_UNIT_SKIPPED=true
        return 1
    fi

    # --preset: 按标签交集过滤
    if [ -n "${DEPLOY_PRESET:-}" ]; then
        local preset
        local matched=false
        local preset_list
        preset_list="$(printf '%s' "${DEPLOY_PRESET:-}" | tr ',' ' ')"

        for preset in $preset_list; do
            local preset_tags
            preset_tags="$(get_preset_tags "$preset" 2>/dev/null || true)"
            [ -z "$preset_tags" ] && continue

            for tag in $unit_tags; do
                if list_contains "$tag" "$preset_tags"; then
                    matched=true
                    break 2
                fi
            done
        done

        if [ "$matched" = false ]; then
            DEPLOY_UNIT_SKIPPED=true
            return 1
        fi
    fi

    return 0
}

# 检查列表（逗号或空格分隔，不区分大小写）是否包含指定值
list_contains() {
    local needle
    needle="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
    local haystack
    haystack="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]' | tr ',' ' ')"

    local item
    for item in $haystack; do
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}