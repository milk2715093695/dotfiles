# 共享渲染逻辑：合并官方 gfw-pac 规则与用户自定义规则，产出 generated/pacproxy/
# 产物目录自包含：合并规则 + 上游源文件 + 生成的 gfw.pac + pacproxy.py 副本
render_pacproxy_assets() {
    local out_dir="$REPO_ROOT/generated/pacproxy"
    local official_dir="$REPO_ROOT/pacproxy/gfw-pac"
    local user_dir="$REPO_ROOT/pacproxy/rules"

    mkdir -p "$out_dir"

    step "渲染 pacproxy 规则产物 -> $out_dir"

    # 合并官方与用户规则，去重保序（用户重复域名不覆盖官方位置；决策时 direct 优先）
    # 官方文件行尾可能无换行符，cat 拼接会粘行，故逐文件补换行并过滤空行
    { cat "$official_dir/direct-domains.txt"; echo; cat "$user_dir/direct-domains.txt"; echo; } 2>/dev/null |
        awk 'NF && !seen[$0]++' > "$out_dir/direct-domains.txt"
    { cat "$official_dir/proxy-domains.txt"; echo; cat "$user_dir/proxy-domains.txt"; echo; } 2>/dev/null |
        awk 'NF && !seen[$0]++' > "$out_dir/proxy-domains.txt"

    cp "$official_dir/local-tlds.txt" "$official_dir/cidrs-cn.txt" "$out_dir/"

    # 生成 PAC：直接指向上游（透明转发），不再经 pacproxy 二次分流
    # gfw-pac.py 以 cwd 读 ./pac-template，须在 official_dir 下执行
    (cd "$official_dir" && python3 gfw-pac.py -f "$out_dir/gfw.pac" \
        -p "PROXY 127.0.0.1:9910" \
        --proxy-domains="$out_dir/proxy-domains.txt" \
        --direct-domains="$out_dir/direct-domains.txt" \
        --localtld-domains="$out_dir/local-tlds.txt" \
        --ip-file="$out_dir/cidrs-cn.txt")

    # 自包含：复制服务脚本，产物目录可独立运行
    cp "$REPO_ROOT/pacproxy/pacproxy.py" "$out_dir/pacproxy.py"

    if [ ! -f "$user_dir/direct-domains.txt" ] || [ ! -f "$user_dir/proxy-domains.txt" ]; then
        warn "pacproxy/rules/ 缺少用户自定义规则（隐私文件，不入库）"
        warn "参考 pacproxy/gfw-pac/direct-domains.txt 创建同名文件后重新部署"
    fi
}