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

# 创建 Cava 配置链接
function New-CavaConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = "$HOME\.config\cava"
    $source = Join-Path $REPO_ROOT "cava\windows"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Test-Cava, Install-Cava, New-CavaConfigLink
