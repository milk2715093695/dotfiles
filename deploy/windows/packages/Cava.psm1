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

# 配置 cava
function Initialize-Cava {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-Cava) {
        Write-Host "cava 已存在，跳过安装。"
    } else {
        Install-ScoopPackage -DeployContext $DeployContext -Name cava
    }

    if (Test-Cava) {
        $target = "$HOME\.config\cava"
        $source = Join-Path $REPO_ROOT "cava\windows"
        New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
    } else {
        Write-WARNING "没有 cava，跳过 cava 配置。"
    }
}

Export-ModuleMember -Function Test-Cava, Initialize-Cava
