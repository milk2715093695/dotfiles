Set-StrictMode -Version Latest

# 检查 WezTerm 是否存在
function Test-WezTerm {
    if (Get-Command wezterm -ErrorAction SilentlyContinue) {
        return $true
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $apps = scoop list 2>$null
        if ($apps -match '^wezterm') {
            return $true
        }
    }

    return $false
}

# 使用 Scoop 安装 WezTerm
function Install-WezTermScoopPackage {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-WARNING "系统未安装 wezterm，且未检测到 scoop。"
        Write-SKIP "将跳过 WezTerm 配置。"
        return
    }

    Write-WARNING "未安装 wezterm，但存在 scoop。"

    if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否使用 scoop 安装 wezterm？") {
        Write-STEP "使用 Scoop 安装 WezTerm"
        scoop install wezterm
    } else {
        Write-SKIP "跳过 WezTerm 安装。"
    }
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

Export-ModuleMember -Function Test-WezTerm, Install-WezTermScoopPackage, New-WezTermConfigLink
