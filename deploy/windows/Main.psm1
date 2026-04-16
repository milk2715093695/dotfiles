Set-StrictMode -Version Latest

# 是否以管理员运行
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 部署入口
function Main {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (-not $IsAdmin) {
        Write-WARNING "当前不是管理员权限运行。"
        Write-WARNING "如果未开启 Windows 开发者模式，创建符号链接可能失败。"
    }

    Initialize-DeployOutputView

    Invoke-DeployStage -Name "安装 AltSnap" -ScriptBlock {
        Install-AltSnap -DeployContext $DeployContext
    }

    Invoke-DeployStage -Name "安装 JetBrains Mono" -ScriptBlock {
        Install-JetBrainsMono -DeployContext $DeployContext
    }

    Invoke-DeployStage -Name "配置 WezTerm" -ScriptBlock {
        Initialize-WezTerm -DeployContext $DeployContext
    }

    Invoke-DeployStage -Name "初始化 PSGallery" -ScriptBlock {
        Initialize-PSGalleryRepository -DeployContext $DeployContext
    }

    Invoke-DeployStage -Name "安装常用命令行工具" -ScriptBlock {
        Install-ScoopPackage -DeployContext $DeployContext -Name @('fd','fzf','zoxide')
    }

    Invoke-DeployStage -Name "配置 Starship" -ScriptBlock {
        Initialize-Starship -DeployContext $DeployContext
    }

    Invoke-DeployStage -Name "配置 PSFzf" -ScriptBlock {
        Initialize-PSFzf
    }

    Invoke-DeployStage -Name "配置 PowerShell" -ScriptBlock {
        Initialize-PWSH -DeployContext $DeployContext
    }

    Invoke-DeployStage -Name "配置 Yazi" -ScriptBlock {
        Initialize-Yazi -DeployContext $DeployContext
    }

    Invoke-DeployStage -Name "配置 Cava" -ScriptBlock {
        Initialize-Cava -DeployContext $DeployContext
    }

    Invoke-DeployStage -Name "配置 LazyVim" -ScriptBlock {
        Initialize-LazyVim -DeployContext $DeployContext
    }

    Write-PLAIN ""
    Write-SUCCESS "部署完成。"
}

Export-ModuleMember -Function Main
