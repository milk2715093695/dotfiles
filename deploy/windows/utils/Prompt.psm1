Set-StrictMode -Version Latest

# 通用确认提示
function Read-Confirmation {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    while ($true) {
        $answer = Read-Host "$Message [y/n]:"
        switch -Regex ($answer) {
            '^[Yy]' { return $true }
            '^[Nn]' { return $false }
            default { Write-WARNING "请输入 y 或 n." }
        }
    }
}

# 只用于安装或更新类确认
function Read-InstallConfirmation {
    param (
        [Parameter(Mandatory)]
        [hashtable]$DeployContext,

        [Parameter(Mandatory)]
        [string]$Message
    )

    if (Get-DeployAutoInstall -DeployContext $DeployContext) {
        Write-INFO "$Message [y/n]: y (自动确认安装)"
        return $true
    }

    return (Read-Confirmation $Message)
}

Export-ModuleMember -Function Read-Confirmation, Read-InstallConfirmation
