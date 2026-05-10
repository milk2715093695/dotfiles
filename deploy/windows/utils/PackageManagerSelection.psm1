Set-StrictMode -Version Latest

$script:PackageManagerPriority = @("scoop", "winget")

# Return package manager priority for Windows deploy.
function Get-PackageManagerPriority {
    return $script:PackageManagerPriority
}

# Check whether a package manager is available on this machine.
function Test-PackageManagerAvailable {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("scoop", "winget")]
        [string]$Manager
    )

    return [bool](Get-Command $Manager -ErrorAction SilentlyContinue)
}

Export-ModuleMember -Function Get-PackageManagerPriority, Test-PackageManagerAvailable, Test-PackageManagerAvailability

# 包管理器预检：确保至少一个受支持的包管理器可用
# Windows 不自动 bootstrap，仅做检测 + 指引 + 中止
function Test-PackageManagerAvailability {
    $available = @()
    foreach ($manager in $script:PackageManagerPriority) {
        if (Test-PackageManagerAvailable -Manager $manager) {
            $available += $manager
        }
    }

    if ($available.Count -gt 0) {
        return $true
    }

    Write-ERROR "未检测到可用包管理器（Scoop 或 winget）。"
    Write-PLAIN ""
    Write-PLAIN "Windows 部署依赖 Scoop 或 winget 作为包管理器。"
    Write-PLAIN "Scoop 安装方法（以普通用户身份打开 PowerShell 执行）："
    Write-PLAIN '  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser'
    Write-PLAIN '  irm get.scoop.sh | iex'
    Write-PLAIN ""
    Write-PLAIN "安装后重新运行部署脚本即可。"

    throw "包管理器预检失败"
}
