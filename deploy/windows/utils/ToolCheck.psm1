Set-StrictMode -Version Latest

# 系统工具预检：在部署开始前检查必需系统命令是否可用

function Test-SystemTools {
    $missing = @()

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        $missing += "git"
    }

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        $missing += "PowerShell 7+"
    }

    if ($missing.Count -eq 0) {
        return $true
    }

    Write-ERROR "部署所需系统工具缺失: $($missing -join ', ')"

    foreach ($tool in $missing) {
        switch ($tool) {
            "git" {
                Write-PLAIN "  git: 从 https://git-scm.com 下载安装 Git for Windows"
            }
            "PowerShell 7+" {
                Write-PLAIN "  PowerShell 7: 当前版本 $($PSVersionTable.PSVersion)，需要 7.0+"
                Write-PLAIN "    安装方式: winget install Microsoft.PowerShell"
                Write-PLAIN "    或: scoop install pwsh"
                Write-PLAIN "    或: https://github.com/PowerShell/PowerShell/releases"
            }
        }
    }

    Write-PLAIN ""
    Write-PLAIN "安装后重新运行部署脚本即可。"

    throw "系统工具预检失败"
}

Export-ModuleMember -Function Test-SystemTools
