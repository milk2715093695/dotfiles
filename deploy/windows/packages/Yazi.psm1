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
    if (Test-Yazi) {
        Write-Host "yazi 已存在，跳过安装。"
    } else {
        Install-ScoopPackage -Name @(
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
        New-SymbolicLink $target $source

        # 安装 yazi 的插件
        ya pkg install
    } else {
        Write-WARNING "没有 yazi，跳过 yazi 配置。"
    }
}

Export-ModuleMember -Function Test-Yazi, Initialize-Yazi
