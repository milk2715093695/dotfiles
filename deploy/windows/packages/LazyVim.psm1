Set-StrictMode -Version Latest

# 检查 NeoVim 是否存在
function Test-Nvim {
    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        return $true
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $apps = scoop list 2>$null
        if ($apps -match '^nvim') {
            return $true
        }
    }

    return $false
}

# 配置 LazyVim
function Initialize-LazyVim {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-Nvim) {
        Write-Host "nvim 已存在，跳过安装。"
    } else {
        Install-ScoopPackage -DeployContext $DeployContext -Name @(
            "neovim", "python", "nodejs", "fd"
        )
    }

    if (Test-Nvim) {
        $target = Join-Path $env:LocalAppData "nvim"
        $source = Join-Path $REPO_ROOT "nvim"
        New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
    } else {
        Write-WARNING "没有 nvim，跳过 lazyvim 配置。"
    }
}

Export-ModuleMember -Function Test-Nvim, Initialize-LazyVim
