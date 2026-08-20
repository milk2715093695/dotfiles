# autostart — 通用启动项注册/撤销工具（posix）
#
# 约定：各模块在 <module>/autostart/<platform>/ 下维护自己的启动项模板，
# 平台差异集中在模板文件内容；本工具只负责统一部署动作（询问/渲染/注册/撤销）。
#   macos:   <module>/autostart/macos/<label>.plist     → 渲染到 ~/Library/LaunchAgents/
#   termux:  <module>/autostart/termux/<name>/run       → 渲染到 $PREFIX/var/service/<name>/run
#            <module>/autostart/termux/<name>/log-run   → 渲染到 $PREFIX/var/service/<name>/log/run
#
# 占位符替换：模块通过 sed 表达式传参（如 s|__PYTHON__|$(command -v python3)|g），本工具不管内容。
# 询问：注册前走 prompt_confirm，--yes-install 自动通过；无 TTY 自动跳过（安全默认）。
#
# 用法：
#   register_autostart <module> <sed_expr...>
#   unregister_autostart <module>

# 启动项注册确认：--yes-install 自动通过，否则询问；无 TTY 由 prompt_confirm 兜底跳过
prompt_autostart_confirm() {
    local message="$1"

    if [ "$(get_deploy_auto_install)" = true ]; then
        info "$message [y/n]: y (自动确认)"
        return 0
    fi

    prompt_confirm "$message"
}

# 构造 sed 参数数组（BSD/GNU 兼容：多表达式必须 -e 前缀，裸传第二个会被当文件名）
# 用法：render_autostart_file <src> <dest> <sed_expr...>
render_autostart_file() {
    local src="$1"
    local dest="$2"
    shift 2

    local sed_args=(-e)
    local expr
    local first=1
    for expr in "$@"; do
        if [ "$first" -eq 1 ]; then
            sed_args+=("$expr")
            first=0
        else
            sed_args+=(-e "$expr")
        fi
    done

    sed "${sed_args[@]}" "$src" > "$dest"
}

# 注册启动项：按 $DEPLOY_PLATFORM 分派
register_autostart() {
    local module="$1"
    shift
    local template_dir="$REPO_ROOT/$module/autostart/$DEPLOY_PLATFORM"

    if [ ! -d "$template_dir" ]; then
        info "autostart: $module 无 $DEPLOY_PLATFORM 模板，跳过"
        return 0
    fi

    case "$DEPLOY_PLATFORM" in
        macos)
            register_autostart_macos "$module" "$template_dir" "$@"
            ;;
        termux)
            register_autostart_termux "$module" "$template_dir" "$@"
            ;;
        *)
            warn "autostart: 未知平台 $DEPLOY_PLATFORM，跳过"
            ;;
    esac
}

# macOS：模板目录下唯一 .plist 文件名即 label，渲染到 ~/Library/LaunchAgents/ 并 bootstrap
register_autostart_macos() {
    local module="$1"
    local template_dir="$2"
    shift 2
    local sed_exprs=("$@")

    local src
    src="$(find "$template_dir" -maxdepth 1 -name '*.plist' | head -n 1)"
    if [ -z "$src" ]; then
        warn "autostart: $module 的 macos 模板目录下没有 .plist"
        return 1
    fi

    local label
    label="$(basename "$src" .plist)"

    if ! prompt_autostart_confirm "是否注册 $module 开机自启（launchd: ${label}）？"; then
        skip_msg "跳过 $module 启动项注册"
        return 0
    fi

    local dest="$HOME/Library/LaunchAgents/$label.plist"
    step "渲染 $label launchd plist -> $dest"
    render_autostart_file "$src" "$dest" "${sed_exprs[@]}" || {
        error "渲染 $label plist 失败"
        return 1
    }

    # bootout + bootstrap 确保新 plist 参数生效（kickstart -k 不重读配置）
    if launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1; then
        step "卸载旧 $label 服务（bootout）"
        launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    fi
    step "加载 $label 服务（bootstrap + enable）"
    launchctl bootstrap "gui/$(id -u)" "$dest"
    launchctl enable "gui/$(id -u)/$label"
    success "已注册 $label 开机自启"
}

# Termux：模板目录下每个子目录即服务名（run + log-run），渲染到 $PREFIX/var/service/ 并 sv restart
register_autostart_termux() {
    local module="$1"
    local template_dir="$2"
    shift 2
    local sed_exprs=("$@")

    local svc_dir
    local name
    local found=0
    for svc_dir in "$template_dir"/*/; do
        [ -d "$svc_dir" ] || continue
        found=1
        name="$(basename "$svc_dir")"

        if ! prompt_autostart_confirm "是否注册 $module 开机自启（runit: ${name}）？"; then
            skip_msg "跳过 $module 启动项注册（${name}）"
            continue
        fi

        local service_dir="$PREFIX/var/service/$name"
        mkdir -p "$service_dir/log"
        render_autostart_file "$svc_dir/run" "$service_dir/run" "${sed_exprs[@]}" || {
            error "渲染 $name run 脚本失败"
            return 1
        }
        chmod +x "$service_dir/run"
        render_autostart_file "$svc_dir/log-run" "$service_dir/log/run" "${sed_exprs[@]}" || {
            error "渲染 $name log-run 脚本失败"
            return 1
        }
        chmod +x "$service_dir/log/run"

        if command -v sv >/dev/null 2>&1; then
            step "重启 $name runit 服务（sv restart）"
            sv restart "$service_dir" 2>/dev/null || true
        else
            warn "未找到 sv，$name 将在下次开机由 Termux:Boot 拉起"
        fi
        success "已注册 $name 开机自启"
    done

    if [ "$found" -eq 0 ]; then
        warn "autostart: $module 的 termux 模板目录为空"
        return 1
    fi
}

# 撤销启动项：按 $DEPLOY_PLATFORM 分派
unregister_autostart() {
    local module="$1"
    local template_dir="$REPO_ROOT/$module/autostart/$DEPLOY_PLATFORM"

    if [ ! -d "$template_dir" ]; then
        info "autostart: $module 无 $DEPLOY_PLATFORM 模板，跳过"
        return 0
    fi

    case "$DEPLOY_PLATFORM" in
        macos)
            unregister_autostart_macos "$template_dir"
            ;;
        termux)
            unregister_autostart_termux "$template_dir"
            ;;
        *)
            warn "autostart: 未知平台 $DEPLOY_PLATFORM，跳过"
            ;;
    esac
}

# macOS：bootout + 删除 LaunchAgents 下的 plist
unregister_autostart_macos() {
    local template_dir="$1"

    local src
    src="$(find "$template_dir" -maxdepth 1 -name '*.plist' | head -n 1)"
    [ -n "$src" ] || return 0

    local label
    label="$(basename "$src" .plist)"
    local dest="$HOME/Library/LaunchAgents/$label.plist"

    if launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1; then
        step "卸载 $label 服务（bootout）"
        launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    fi
    if [ -f "$dest" ]; then
        step "删除 $dest"
        rm -f "$dest"
    fi
    success "已撤销 $label 开机自启"
}

# Termux：sv down + 删除 $PREFIX/var/service/ 下的服务目录
unregister_autostart_termux() {
    local template_dir="$1"

    local svc_dir
    local name
    for svc_dir in "$template_dir"/*/; do
        [ -d "$svc_dir" ] || continue
        name="$(basename "$svc_dir")"
        local service_dir="$PREFIX/var/service/$name"

        if command -v sv >/dev/null 2>&1 && [ -d "$service_dir" ]; then
            step "停止 $name runit 服务（sv down）"
            sv down "$service_dir" 2>/dev/null || true
        fi
        if [ -d "$service_dir" ]; then
            step "删除 $service_dir"
            rm -rf "$service_dir"
        fi
        success "已撤销 $name 开机自启"
    done
}
