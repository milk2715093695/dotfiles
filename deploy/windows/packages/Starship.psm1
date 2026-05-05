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

    Install-SoftwareKey -DeployContext $DeployContext -Key "shell.starship"
}

# 渲染 Starship 配置
function New-StarshipRenderConfig {
    Write-STEP "渲染 Starship 配置"

    $generatedDir = Join-Path $REPO_ROOT "generated\starship"
    New-Item -ItemType Directory -Path $generatedDir -Force | Out-Null

    Invoke-RenderConfigFile `
        -Source (Join-Path $REPO_ROOT "starship\starship.toml") `
        -Output (Join-Path $generatedDir "starship.toml")
}

# 创建 Starship 配置链接
function New-StarshipConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = "$HOME\.config\starship.toml"
    $source = "$REPO_ROOT\generated\starship\starship.toml"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Test-Starship, Install-Starship, New-StarshipRenderConfig, New-StarshipConfigLink
