Set-StrictMode -Version Latest

# 检查 JetBrains Mono 字体是否存在
function Test-JetBrainsMono {
    $fontInstalled = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "JetBrainsMono" }

    return [bool]$fontInstalled
}

# 安装 JetBrains Mono 字体
function Install-JetBrainsMono {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-JetBrainsMono) {
        Write-SKIP "JetBrains Mono 已安装，跳过字体安装。"
        return
    }

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-WARNING "未安装 JetBrains Mono，但存在 scoop。"

        if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否使用 scoop 安装 JetBrains Mono？") {
            Write-STEP "使用 Scoop 安装 JetBrains Mono"
            scoop bucket add nerd-fonts
            scoop install jetbrains-mono
        } else {
            Write-SKIP "跳过字体安装。"
        }
        return
    }

    Write-WARNING "未检测到 scoop，无法自动安装 JetBrains Mono。"
    Write-INFO "请手动安装字体，或自行扩展脚本。"
}

Export-ModuleMember -Function Test-JetBrainsMono, Install-JetBrainsMono
