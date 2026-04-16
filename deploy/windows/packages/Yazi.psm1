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

# 配置 Yazi
function Initialize-Yazi {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-Yazi) {
        Write-SKIP "Yazi 已存在，跳过安装。"
    } else {
        Install-ScoopPackage -DeployContext $DeployContext -Name @(
            "yazi", "ffmpeg", "7zip",
            "jq", "poppler", "fd",
            "ripgrep", "fzf", "zoxide",
            "resvg", "imagemagick", "clipboard",
            "bat", "less", "glow",
            "file"
        )
    }

    if (Test-Yazi) {
        $target = Join-Path $env:AppData "yazi\config"
        $source = Join-Path $REPO_ROOT "yazi"
        New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source

        # 插件安装属于安装类操作，可由 -YesInstall 自动确认
        if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否安装或更新 yazi 插件？") {
            Write-STEP "安装或更新 Yazi 插件"
            ya pkg install
        } else {
            Write-SKIP "跳过 Yazi 插件安装。"
        }
    } else {
        Write-WARNING "没有 Yazi，跳过 Yazi 配置。"
    }
}

Export-ModuleMember -Function Test-Yazi, Initialize-Yazi
