Set-StrictMode -Version Latest

# 创建部署上下文
function New-DeployContext {
    param(
        [Parameter(Mandatory)]
        [bool]$AutoInstall,

        [Parameter(Mandatory)]
        [string]$ConfigMode
    )

    return @{
        AutoInstall = $AutoInstall
        ConfigMode = $ConfigMode
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

Export-ModuleMember -Function New-DeployContext, Get-DeployAutoInstall, Get-DeployConfigMode, Set-DeployConfigMode
