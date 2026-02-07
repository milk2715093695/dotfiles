Set-StrictMode -Version Latest

# 交互函数
function Read-Confirmation {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    # 如果 AUTO_CONFIRM=true，则自动确认
    if ($env:AUTO_CONFIRM -eq "true") {
        Write-Host "$Message [y/n]: y (自动确认)"
        return $true
    }

    while ($true) {
        $answer = Read-Host "$Message [y/n]"
        switch -Regex ($answer) {
            '^[Yy]' { return $true }
            '^[Nn]' { return $false }
            default { Write-Host "请输入 y 或 n." }
        }
    }
}

Export-ModuleMember -Function Read-Confirmation
