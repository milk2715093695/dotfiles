Set-StrictMode -Version Latest

# 检查 Neovim 是否存在
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

# 检查 LazyVim deploy unit 是否可用
function Test-LazyVim {
    Test-Nvim
}

# 安装 LazyVim 运行时依赖
function Install-LazyVim {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-ScoopPackage -DeployContext $DeployContext -Name @(
        "neovim", "python", "nodejs", "fd"
    )
}

# 创建 LazyVim 配置链接
function New-LazyVimConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = Join-Path $env:LocalAppData "nvim"
    $source = Join-Path $REPO_ROOT "nvim"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Test-Nvim, Test-LazyVim, Install-LazyVim, New-LazyVimConfigLink
