Set-StrictMode -Version Latest

# 检查 Starship 是否存在
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

# 配置 Starship
function Initialize-Starship {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-Starship) {
        Write-SKIP "Starship 已存在，跳过安装。"
    } else {
        Install-ScoopPackage -DeployContext $DeployContext -Name starship
    }

    if (Test-Starship) {
        $target = "$HOME\.config\starship.toml"
        $source = "$REPO_ROOT\starship\starship.toml"
        New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
    } else {
        Write-WARNING "没有 Starship，跳过 Starship 配置。"
    }
}

Export-ModuleMember -Function Initialize-Starship
