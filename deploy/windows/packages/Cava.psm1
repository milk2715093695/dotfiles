Set-StrictMode -Version Latest

# 检查 Cava 是否存在
function Test-Cava {
    if (Get-Command cava -ErrorAction SilentlyContinue) {
        return $true
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $apps = scoop list 2>$null
        if ($apps -match '^cava') {
            return $true
        }
    }

    return $false
}

# 配置 Cava
function Initialize-Cava {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-Cava) {
        Write-SKIP "Cava 已存在，跳过安装。"
    } else {
        Install-ScoopPackage -DeployContext $DeployContext -Name cava
    }

    if (Test-Cava) {
        $target = "$HOME\.config\cava"
        $source = Join-Path $REPO_ROOT "cava\windows"
        New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
    } else {
        Write-WARNING "没有 Cava，跳过 Cava 配置。"
    }
}

Export-ModuleMember -Function Test-Cava, Initialize-Cava
