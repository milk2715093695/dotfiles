Set-StrictMode -Version Latest

# autostart — 通用启动项注册/撤销工具（Windows）
#
# Windows 计划任务的 Execute/Argument 依赖运行时路径（python 等），
# 无法像 posix 用静态模板文件表达，故用函数抽象，语义与 posix autostart.sh 一致：
#   注册前询问（--yes-install 自动通过，无 TTY 由 Read-Confirmation 兜底），
#   支持注册与撤销。
#
# 用法：
#   Register-AutostartTask -DeployContext $DeployContext -Name "pacproxy" `
#       -Execute $python -Argument $arguments [-Description "..."] [-RestartOnFailure]
#   Unregister-AutostartTask -Name "pacproxy"

# 注册计划任务（登录触发；可选失败每分钟重启）
function Register-AutostartTask {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Execute,

        [Parameter(Mandatory)]
        [string[]]$Argument,

        [Parameter()]
        [string]$Description = "",

        [Parameter()]
        [switch]$RestartOnFailure
    )

    # 注册前询问（--yes-install 自动通过）
    $message = "是否注册 $Name 开机自启（计划任务）？"
    $auto = Get-DeployAutoInstall -DeployContext $DeployContext
    if (-not $auto) {
        $answer = Read-Confirmation $message
        if (-not $answer) {
            Write-SKIP "跳过 $Name 启动项注册"
            return
        }
    } else {
        Write-INFO "$message [y/n]: y (自动确认)"
    }

    Write-STEP "注册计划任务 $Name"
    $action = New-ScheduledTaskAction -Execute $Execute -Argument ($Argument -join ' ')
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    if ($RestartOnFailure) {
        $settings = New-ScheduledTaskSettingsSet `
            -MultipleInstances IgnoreNew `
            -ExecutionTimeLimit ([TimeSpan]::Zero) `
            -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) `
            -StartWhenAvailable
    } else {
        $settings = New-ScheduledTaskSettingsSet `
            -MultipleInstances IgnoreNew `
            -ExecutionTimeLimit ([TimeSpan]::Zero) `
            -StartWhenAvailable
    }
    Register-ScheduledTask -TaskName $Name -Action $action -Trigger $trigger -Settings $settings -Description $Description -Force | Out-Null
    Write-SUCCESS "已注册计划任务 $Name（登录触发）"
}

# 撤销计划任务
function Unregister-AutostartTask {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $task = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    if ($null -eq $task) {
        Write-INFO "计划任务 $Name 不存在，跳过撤销"
        return
    }

    Write-STEP "撤销计划任务 $Name"
    Unregister-ScheduledTask -TaskName $Name -Confirm:$false
    Write-SUCCESS "已撤销计划任务 $Name"
}

Export-ModuleMember -Function Register-AutostartTask, Unregister-AutostartTask
