Set-StrictMode -Version Latest

# 检查 fastfetch 是否存在
function Test-Fastfetch {
    Test-SoftwareAvailable -Key "shell.fastfetch"
}

# 安装 fastfetch
function Install-Fastfetch {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-SoftwareKey -DeployContext $DeployContext -Key "shell.fastfetch"
}

# 创建 fastfetch 配置链接
function New-FastfetchConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = Join-Path $HOME ".config\fastfetch"
    $source = Join-Path $REPO_ROOT "fastfetch"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Test-Fastfetch, Install-Fastfetch, New-FastfetchConfigLink
