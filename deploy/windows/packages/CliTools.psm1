Set-StrictMode -Version Latest

$script:CliToolSetPackages = @("fd", "fzf", "zoxide")

# 检查单个 Scoop 工具是否存在
function Test-CliTool {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        return $true
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $apps = scoop list 2>$null
        if ($apps -match "^$Name\s") {
            return $true
        }
    }

    return $false
}

# 检查常用命令行工具是否存在
function Test-CliToolSet {
    foreach ($pkg in $script:CliToolSetPackages) {
        if (-not (Test-CliTool -Name $pkg)) {
            return $false
        }
    }

    return $true
}

# 安装常用命令行工具
function Install-CliToolSet {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-ScoopPackage -DeployContext $DeployContext -Name $script:CliToolSetPackages
}

Export-ModuleMember -Function Test-CliToolSet, Install-CliToolSet
