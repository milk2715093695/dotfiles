Set-StrictMode -Version Latest

# 检查 Cava 是否存在
function Test-Cava {
    if (Get-Command cava -ErrorAction SilentlyContinue) {
        return $true
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $apps = scoop list 2>$null
        if ($apps -match '^cava') {
            return $true
        }
    }

    return $false
}

# 安装 Cava
function Install-Cava {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-ScoopPackage -DeployContext $DeployContext -Name cava
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
