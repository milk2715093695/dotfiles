# 检查 SketchyBar 是否完整可用（二进制 + SbarLua + icon_map）
check_sketchybar_available() {
    command -v sketchybar >/dev/null 2>&1 || return 1
    [ -f "$HOME/.local/share/sketchybar_lua/sketchybar.so" ] || return 1
    [ -f "$REPO_ROOT/sketchybar/config/icon_map.lua" ] || return 1
}

# 准备 SketchyBar 运行时依赖（aerospace）
prepare_sketchybar_deps() {
    if command -v aerospace >/dev/null 2>&1; then
        return 0
    fi

    if prompt_install_confirm "SketchyBar 工作区组件需要 Aerospace，是否安装？"; then
        step "安装 Aerospace"
        brew tap FelixKratz/formulae 2>/dev/null || true
        brew install aerospace
    else
        warn "跳过 Aerospace，SketchyBar 工作区组件将不可用"
    fi
}

# 安装 SketchyBar（调用子模块黑盒安装脚本）
install_sketchybar_package() {
    local install_script="$REPO_ROOT/sketchybar/install_sketchybar.sh"

    if [ ! -f "$install_script" ]; then
        error "未找到 sketchybar 安装脚本：$install_script"
        error "请确认 sketchybar 子模块已初始化：git submodule update --init sketchybar"
        return 1
    fi

    step "执行 sketchybar 安装脚本"
    bash "$install_script"
}

# 链接 SketchyBar 配置（Lua 动态加载，无需 render 阶段）
link_sketchybar_config() {
    link_item "$HOME/.config/sketchybar" "$REPO_ROOT/sketchybar"
}
