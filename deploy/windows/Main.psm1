Set-StrictMode -Version Latest

# 是否以管理员运行
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 函数入口
function Main {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (-not $IsAdmin) {
        Write-WARNING "当前不是管理员权限运行。"
        Write-Host "如果未开启 Windows 开发者模式，创建符号链接可能失败。"
    }

    Install-AltSnap -DeployContext $DeployContext

    Install-JetBrainsMono -DeployContext $DeployContext

    Initialize-WezTerm -DeployContext $DeployContext

    Initialize-PSGalleryRepository

    Install-ScoopPackage -DeployContext $DeployContext -Name @('fd','fzf','zoxide')

    Initialize-Starship -DeployContext $DeployContext

    Initialize-PSFzf

    Initialize-PWSH -DeployContext $DeployContext

    Initialize-Yazi -DeployContext $DeployContext

    Initialize-Cava -DeployContext $DeployContext

    Initialize-LazyVim -DeployContext $DeployContext

    Write-Host ""
    Write-SUCCESS "部署完成。"
}

Export-ModuleMember -Function Main
