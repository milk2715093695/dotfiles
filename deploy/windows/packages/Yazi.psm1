Set-StrictMode -Version Latest

# 检查 Yazi 是否存在
function Test-Yazi {
    Test-SoftwareAvailable -Key "filemanager.yazi"
}

# 安装 Yazi 配置所需运行时依赖
function Install-YaziRuntimeDependencies {
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

# 安装或更新 Yazi 插件包
function Install-OrUpdateYaziPackages {
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

Export-ModuleMember -Function Test-Yazi, Install-YaziRuntimeDependencies, New-YaziConfigLink, Install-OrUpdateYaziPackages
