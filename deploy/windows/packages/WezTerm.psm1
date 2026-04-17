Set-StrictMode -Version Latest

# 检查 WezTerm 是否存在
function Test-WezTerm {
    Test-SoftwareAvailable -Key "terminal.wezterm"
}

# 安装 WezTerm
function Install-WezTermPackage {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-SoftwareKey -DeployContext $DeployContext -Key "terminal.wezterm"
}

# 创建 WezTerm 配置链接
function New-WezTermConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = "$HOME\.config\wezterm"
    $source = Join-Path $REPO_ROOT "wezterm"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Test-WezTerm, Install-WezTermPackage, New-WezTermConfigLink
