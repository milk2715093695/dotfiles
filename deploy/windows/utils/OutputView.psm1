Set-StrictMode -Version Latest

$script:DeployStageSummaries = @()
$script:DeployStageSkippedReason = "DeployStageSkipped"

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
        switch ($summary.Level) {
            "SKIP" { Write-SKIP $summary.Message }
            default { Write-INFO $summary.Message }
        }
    }
}

# 记录顶层阶段摘要
function Add-DeployStageSummary {
    param(
        [Parameter(Mandatory)]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $script:DeployStageSummaries += [pscustomobject]@{
        Level = $Level
        Message = $Message
    }
}

# 记录并输出阶段开始摘要
function Start-DeployStage {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $summary = "开始$Name"
    Add-DeployStageSummary -Level "INFO" -Message $summary
    Write-INFO $summary
}

# 记录阶段完成摘要，并在成功路径重绘视图
function Complete-DeployStage {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $summary = "$Name 完成"
    Add-DeployStageSummary -Level "INFO" -Message $summary

    if (Test-DeployOutputViewResetEnabled) {
        Show-DeployOutputSummary
    } else {
        Write-INFO $summary
    }
}

# 记录阶段跳过摘要，并在跳过路径重绘视图
function Skip-DeployStage {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $summary = "$Name 跳过"
    Add-DeployStageSummary -Level "SKIP" -Message $summary

    if (Test-DeployOutputViewResetEnabled) {
        Show-DeployOutputSummary
    } else {
        Write-SKIP $summary
    }
}

# 发出 deploy stage 稳定跳过信号
function New-DeployStageSkippedException {
    $exception = [System.Exception]::new($script:DeployStageSkippedReason)
    $exception.Data["DeployStageStatus"] = $script:DeployStageSkippedReason
    return $exception
}

# 判断异常是否表示 deploy stage 稳定跳过
function Test-DeployStageSkippedException {
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $exception = $ErrorRecord.Exception
    return $exception.Data.Contains("DeployStageStatus") -and `
        $exception.Data["DeployStageStatus"] -eq $script:DeployStageSkippedReason
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
    try {
        & $ScriptBlock
    } catch {
        if (Test-DeployStageSkippedException -ErrorRecord $_) {
            Skip-DeployStage -Name $Name
            return
        }

        throw
    }

    Complete-DeployStage -Name $Name
}

Export-ModuleMember -Function Initialize-DeployOutputView, Invoke-DeployStage, New-DeployStageSkippedException
