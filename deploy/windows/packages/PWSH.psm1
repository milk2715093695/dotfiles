Set-StrictMode -Version Latest

# 询问并将 pwsh 设为 OpenSSH 默认 shell
function Set-PwshOpenSshDefaultShell {
    if (Read-Confirmation "是否将 pwsh 设为默认 ssh 登录客户端？") {
        $pwshPath = (where.exe pwsh 2>$null | Select-Object -First 1)

        if (-not $pwshPath) {
            Write-ERROR "未找到 pwsh.exe，请确认已安装 PowerShell 7。"
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
}

# 创建 PowerShell 配置链接
function New-PwshConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = "$PROFILE"
    $source = "$REPO_ROOT\pwsh\Microsoft.PowerShell_profile.ps1"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source

    $target = "$HOME\.config\pwsh"
    $source = "$REPO_ROOT\pwsh\pwsh"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Set-PwshOpenSshDefaultShell, New-PwshConfigLink
