Set-StrictMode -Version Latest

# 是否以管理员运行
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 函数入口
function Main {
    if (-not $IsAdmin) {
        Write-WARNING "当前不是管理员权限运行。"
        Write-Host "如果未开启 Windows 开发者模式，创建符号链接可能失败。"
    }

    Install-AltSnap

    Install-JetBrainsMono

    Initialize-WezTerm

    Write-Host ""
    Write-INFO "部署完成。"
}

Export-ModuleMember -Function Main
