Set-StrictMode -Version Latest

# 创建部署上下文
function New-DeployContext {
    param(
        [Parameter(Mandatory)]
        [bool]$AutoInstall,

        [Parameter(Mandatory)]
        [string]$ConfigMode,

        [Parameter(Mandatory)]
        [string]$Preset,

        [Parameter(Mandatory)]
        [string]$SkipUnits,

        [Parameter(Mandatory)]
        [string]$OnlyUnits
    )

    # --only 和 --preset 互斥校验
    if ($OnlyUnits -and $Preset) {
        Write-WARNING "-Only 和 -Preset 互斥，-Only 生效时 -Preset 被忽略"
        $Preset = ""
    }

    return @{
        AutoInstall = $AutoInstall
        ConfigMode  = $ConfigMode
        Preset      = $Preset
        SkipUnits   = $SkipUnits
        OnlyUnits   = $OnlyUnits
    }
}

# 读取自动安装开关
function Get-DeployAutoInstall {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    return [bool]$DeployContext.AutoInstall
}

# 读取配置冲突模式
function Get-DeployConfigMode {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $mode = [string]$DeployContext.ConfigMode
    if ([string]::IsNullOrWhiteSpace($mode)) {
        return "ask"
    }

    return $mode
}

# 更新配置冲突模式
function Set-DeployConfigMode {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext,

        [Parameter(Mandatory)]
        [string]$ConfigMode
    )

    $DeployContext.ConfigMode = $ConfigMode
}

# 读取预设过滤
function Get-DeployPreset {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $val = [string]$DeployContext.Preset
    if ([string]::IsNullOrWhiteSpace($val)) { return "" }
    return $val
}

# 读取排除单元列表
function Get-DeploySkipUnits {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $val = [string]$DeployContext.SkipUnits
    if ([string]::IsNullOrWhiteSpace($val)) { return @() }
    return @($val -split ',' | ForEach-Object { $_.Trim().ToLowerInvariant() })
}

# 读取仅部署单元列表
function Get-DeployOnlyUnits {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $val = [string]$DeployContext.OnlyUnits
    if ([string]::IsNullOrWhiteSpace($val)) { return @() }
    return @($val -split ',' | ForEach-Object { $_.Trim().ToLowerInvariant() })
}

Export-ModuleMember -Function New-DeployContext, Get-DeployAutoInstall, Get-DeployConfigMode, Set-DeployConfigMode, Get-DeployPreset, Get-DeploySkipUnits, Get-DeployOnlyUnits
