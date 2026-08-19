Set-StrictMode -Version Latest

# 检查 Python 运行时是否存在
function Test-PacproxyRuntime {
    return $null -ne (Get-Command python -ErrorAction SilentlyContinue)
}

# 初始化 gfw-pac 规则子模块，引导本地覆盖层文件
function Render-PacproxyTask {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-Path (Join-Path $REPO_ROOT "proxy\gfw-pac\.git")) {
        Write-SKIP "gfw-pac 子模块已就位，跳过初始化"
    } else {
        Write-STEP "初始化 gfw-pac 规则子模块"
        Push-Location $REPO_ROOT
        try {
            git submodule update --init proxy/gfw-pac 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-WARNING "git submodule 注册不可用（尚未提交），改用 git clone 兜底"
                git clone --depth 1 https://github.com/zhiyi7/gfw-pac.git proxy/gfw-pac
            }
            if ($LASTEXITCODE -ne 0) { throw "gfw-pac 子模块初始化失败" }
        } finally {
            Pop-Location
        }
    }

    $rulesDir = Join-Path $REPO_ROOT "proxy\rules"
    if (-not (Test-Path (Join-Path $rulesDir "new_direct.txt")) -or -not (Test-Path (Join-Path $rulesDir "new_proxy.txt"))) {
        Write-WARNING "proxy\rules\ 缺少本地覆盖层（隐私文件，不入库）"
        Write-WARNING "参考 proxy\rules\example_*.txt 创建 new_direct.txt / new_proxy.txt"
    }
}

# 创建配置链接（符号链接失败时回退目录联接，SSH 过滤令牌场景）并注册计划任务
function New-PacproxyConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = Join-Path $HOME ".config\pacproxy"
    $source = Join-Path $REPO_ROOT "proxy"

    if (-not (Test-TargetExists $target)) {
        $parent = Split-Path -Parent $target
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
        try {
            New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
            Write-SUCCESS "已创建符号链接：$target -> $source"
        } catch {
            Write-WARNING "符号链接需要管理员/开发者模式（当前为过滤令牌），回退为目录联接"
            New-Item -ItemType Junction -Path $target -Target $source | Out-Null
            Write-SUCCESS "已创建目录联接：$target -> $source"
        }
    } else {
        New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
    }

    $python = (Get-Command python -ErrorAction Stop).Source
    $configDir = Join-Path $HOME ".config\pacproxy"
    $arguments = "$configDir\pacproxy.py --rules-dir $configDir\gfw-pac --overlay-dir $configDir\rules --log $configDir\pacproxy.log"

    Write-STEP "注册计划任务 pacproxy"
    $action = New-ScheduledTaskAction -Execute $python -Argument $arguments
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $settings = New-ScheduledTaskSettingsSet `
        -MultipleInstances IgnoreNew `
        -ExecutionTimeLimit ([TimeSpan]::Zero) `
        -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) `
        -StartWhenAvailable
    Register-ScheduledTask -TaskName "pacproxy" -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
    Write-SUCCESS "已注册计划任务 pacproxy（登录触发，失败每分钟重启）"
}

Export-ModuleMember -Function Test-PacproxyRuntime, Render-PacproxyTask, New-PacproxyConfigLink
