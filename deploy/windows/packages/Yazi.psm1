Set-StrictMode -Version Latest

# 检查 Yazi 是否存在
function Test-Yazi {
    Test-SoftwareAvailable -Key "filemanager.yazi"
}

# 安装 Yazi 配置所需运行时依赖
function Install-YaziRuntimeDependencies {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-SoftwareKey -DeployContext $DeployContext -Key "filemanager.yazi"
}

# 渲染 Yazi 配置
function New-YaziRenderConfig {
    Write-STEP "渲染 Yazi 配置"

    $generatedDir = Join-Path $REPO_ROOT "generated\yazi"
    New-Item -ItemType Directory -Path $generatedDir -Force | Out-Null

    Invoke-RenderConfigFile `
        -Source (Join-Path $REPO_ROOT "yazi\yazi.toml") `
        -Output (Join-Path $generatedDir "yazi.toml")

    Invoke-RenderConfigFile `
        -Source (Join-Path $REPO_ROOT "yazi\keymap.toml") `
        -Output (Join-Path $generatedDir "keymap.toml")

    Invoke-RenderConfigFile `
        -Source (Join-Path $REPO_ROOT "yazi\vfs.toml") `
        -Output (Join-Path $generatedDir "vfs.toml")

    Copy-Item (Join-Path $REPO_ROOT "yazi\theme.toml") (Join-Path $generatedDir "theme.toml") -Force
    Copy-Item (Join-Path $REPO_ROOT "yazi\package.toml") (Join-Path $generatedDir "package.toml") -Force
    Copy-Item (Join-Path $REPO_ROOT "yazi\init.lua") (Join-Path $generatedDir "init.lua") -Force
}

# 创建 Yazi 配置链接
function New-YaziConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = Join-Path $env:AppData "yazi\config"
    $source = Join-Path $REPO_ROOT "generated\yazi"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

# 安装或更新 Yazi 插件包
function Install-OrUpdateYaziPackages {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否安装或更新 yazi 插件？") {
        Write-STEP "安装或更新 Yazi 插件"
        ya pkg install
    } else {
        Write-SKIP "跳过 Yazi 插件安装。"
    }
}

Export-ModuleMember -Function Test-Yazi, Install-YaziRuntimeDependencies, New-YaziRenderConfig, New-YaziConfigLink, Install-OrUpdateYaziPackages
