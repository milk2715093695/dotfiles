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

# 使用 scoop 安装 WezTerm
function Install-WezTerm {
    Write-WARNING "未安装 wezterm，但存在 scoop。" -ForegroundColor

    if (Read-Confirmation "是否使用 scoop 安装 wezterm？") {
        scoop install wezterm
    } else {
        Write-Host "跳过 wezterm 安装。"
    }
}

# 配置 WezTerm
function Initialize-WezTerm {

    if (Test-WezTerm) {
        Write-Host "wezterm 已存在，跳过安装。"
    } else {
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Install-WezTerm
        } else {
            Write-WARNING "系统未安装 wezterm，且未检测到 scoop。"
            Write-Host "将跳过 wezterm 配置。"
        }
    }

    if (Test-WezTerm) {
        $target = "$env:USERPROFILE\.config\wezterm"
        $source = Join-Path $REPO_ROOT "wezterm"
        New-SymbolicLink $target $source
    } else {
        Write-WARNING "没有 wezterm，跳过 wezterm 配置。"
    }
}

Export-ModuleMember -Function Test-WezTerm, Install-WezTerm, Initialize-WezTerm
