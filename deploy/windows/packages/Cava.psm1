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

    $localsDir = Join-Path $REPO_ROOT "cava\windows\locals"

    Invoke-RenderConfigFile `
        -Source (Join-Path $REPO_ROOT "cava\windows\config") `
        -LocalsDir $localsDir `
        -Output (Join-Path $generatedDir "config")
}

# 创建 Cava 配置链接
function New-CavaConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $configTarget  = Join-Path $HOME ".config\cava\config"
    $configSource  = Join-Path $REPO_ROOT "generated\cava\config"
    $themesTarget  = Join-Path $HOME ".config\cava\themes"
    $themesSource  = Join-Path $REPO_ROOT "cava\common\themes"
    $shadersTarget = Join-Path $HOME ".config\cava\shaders"
    $shadersSource = Join-Path $REPO_ROOT "cava\common\shaders"

    New-SymbolicLink -DeployContext $DeployContext -TargetPath $configTarget  -SourcePath $configSource
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $themesTarget  -SourcePath $themesSource
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $shadersTarget -SourcePath $shadersSource
}

Export-ModuleMember -Function Test-Cava, Install-Cava, New-CavaRenderConfig, New-CavaConfigLink
