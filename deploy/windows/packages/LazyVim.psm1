Set-StrictMode -Version Latest

# 检查 Neovim 命令是否可用
function Test-NeovimCommand {
    Test-SoftwareAvailable -Key "editor.neovim"
}

# 检查 LazyVim 配置所需运行时是否可用
function Test-LazyVimRuntime {
    Test-NeovimCommand
}

# 安装 LazyVim 配置所需运行时依赖
function Install-LazyVimRuntimeDependencies {
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

Export-ModuleMember -Function Test-NeovimCommand, Test-LazyVimRuntime, Install-LazyVimRuntimeDependencies, New-LazyVimConfigLink
