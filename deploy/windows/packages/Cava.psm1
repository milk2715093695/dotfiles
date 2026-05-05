Set-StrictMode -Version Latest

# 检查 Cava 是否存在
function Test-Cava {
    Test-SoftwareAvailable -Key "audio.cava"
}

# 安装 Cava
function Install-Cava {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-SoftwareKey -DeployContext $DeployContext -Key "audio.cava"
}

# 渲染 Cava 配置
function New-CavaRenderConfig {
    Write-STEP "渲染 Cava 配置"

    $generatedDir = Join-Path $REPO_ROOT "generated\cava"
    New-Item -ItemType Directory -Path $generatedDir -Force | Out-Null

    Invoke-RenderConfigFile `
        -Source (Join-Path $REPO_ROOT "cava\windows\config") `
        -Output (Join-Path $generatedDir "config")

    Copy-Item (Join-Path $REPO_ROOT "cava\common\themes") (Join-Path $generatedDir "themes") -Recurse -Force
    Copy-Item (Join-Path $REPO_ROOT "cava\common\shaders") (Join-Path $generatedDir "shaders") -Recurse -Force
}

# 创建 Cava 配置链接
function New-CavaConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = Join-Path $HOME ".config\cava"
    $source = Join-Path $REPO_ROOT "generated\cava"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Test-Cava, Install-Cava, New-CavaRenderConfig, New-CavaConfigLink
