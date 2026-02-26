Set-StrictMode -Version Latest

# 检查 starship 是否已经安装
function Test-Starship {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        return $true
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $apps = scoop list 2>$null
        if ($apps -match "starship") {
            return $true
        }
    }

    return $false
}

function Initialize-Starship {
    if (Test-Starship) {
        Write-Host "wezterm 已存在，跳过安装。"
    } else {
        Install-ScoopPackage starship
    }

    if (Test-Starship) {
        $target = "$HOME\.config\starship.toml"
        $source = "$REPO_ROOT\starship\starship.toml"
        New-SymbolicLink $target $source
    } else {
        Write-Warning "没有 starship，跳过 starship 配置"
    }
}

Export-ModuleMember -Function Initialize-Starship
