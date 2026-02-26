Set-StrictMode -Version Latest

# 配置 pwsh
function Initialize-PWSH {
    if (Read-Confirmation "是否将 pwsh 设为默认 ssh 登录客户端？") {
        $pwshPath = (where.exe pwsh 2>$null | Select-Object -First 1)

        if (-not $pwshPath) {
            Write-Error "未找到 pwsh.exe，请确认已安装 PowerShell 7。"
            return
        }

        New-ItemProperty `
            -Path "HKLM:\SOFTWARE\OpenSSH" `
            -Name DefaultShell `
            -Value "$pwshPath" `
            -PropertyType String `
            -Force

        Restart-Service sshd
    }

    $target = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    $target = "$PROFILE"
    $source = "$REPO_ROOT\pwsh\Microsoft.PowerShell_profile.ps1"
    New-SymbolicLink $target $source

    $target = "$HOME\.config\pwsh"
    $source = "$REPO_ROOT\pwsh\pwsh"
    New-SymbolicLink $target $source
}

Export-ModuleMember -Function Initialize-PWSH
