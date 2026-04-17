Set-StrictMode -Version Latest

# 检查 Starship 是否存在
function Test-Starship {
    Test-SoftwareAvailable -Key "shell.starship"
}

# 安装 Starship
function Install-Starship {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-ScoopPackage -DeployContext $DeployContext -Name starship
}

# 创建 Starship 配置链接
function New-StarshipConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = "$HOME\.config\starship.toml"
    $source = "$REPO_ROOT\starship\starship.toml"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Test-Starship, Install-Starship, New-StarshipConfigLink
