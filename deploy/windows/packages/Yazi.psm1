Set-StrictMode -Version Latest

# 检查 Yazi 是否存在
function Test-Yazi {
    if (Get-Command yazi -ErrorAction SilentlyContinue) {
        return $true
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $apps = scoop list 2>$null
        if ($apps -match '^yazi') {
            return $true
        }
    }

    return $false
}

# 安装 Yazi 运行时依赖
function Install-Yazi {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-ScoopPackage -DeployContext $DeployContext -Name @(
        "yazi", "ffmpeg", "7zip",
        "jq", "poppler", "fd",
        "ripgrep", "fzf", "zoxide",
        "resvg", "imagemagick", "clipboard",
        "bat", "less", "glow",
        "file"
    )
}

# 创建 Yazi 配置链接
function New-YaziConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = Join-Path $env:AppData "yazi\config"
    $source = Join-Path $REPO_ROOT "yazi"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

# 更新 Yazi 插件
function Update-YaziPlugin {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否安装或更新 yazi 插件？") {
        Write-STEP "安装或更新 Yazi 插件"
        ya pkg install
    } else {
        Write-SKIP "跳过 Yazi 插件安装。"
    }
}

Export-ModuleMember -Function Test-Yazi, Install-Yazi, New-YaziConfigLink, Update-YaziPlugin
