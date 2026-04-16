Set-StrictMode -Version Latest

$script:DeployStageSummaries = @()

# 初始化部署输出视图
function Initialize-DeployOutputView {
    $script:DeployStageSummaries = @()
}

# 判断是否启用摘要重绘
function Test-DeployOutputViewResetEnabled {
    if ([Console]::IsOutputRedirected) {
        return $false
    }

    if (-not [string]::IsNullOrWhiteSpace($env:CI)) {
        return $false
    }

    return $true
}

# 重绘已完成阶段摘要
function Show-DeployOutputSummary {
    if (-not (Test-DeployOutputViewResetEnabled)) {
        return
    }

    Clear-Host
    foreach ($summary in $script:DeployStageSummaries) {
        Write-INFO $summary
    }
}

# 记录并输出阶段开始摘要
function Start-DeployStage {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $summary = "开始$Name"
    $script:DeployStageSummaries += $summary
    Write-INFO $summary
}

# 记录阶段完成摘要，并在成功路径重绘视图
function Complete-DeployStage {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $summary = "$Name 完成"
    $script:DeployStageSummaries += $summary

    if (Test-DeployOutputViewResetEnabled) {
        Show-DeployOutputSummary
    } else {
        Write-INFO $summary
    }
}

# 执行一个顶层部署阶段
function Invoke-DeployStage {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock
    )

    Start-DeployStage -Name $Name
    & $ScriptBlock
    Complete-DeployStage -Name $Name
}

Export-ModuleMember -Function Initialize-DeployOutputView, Invoke-DeployStage
