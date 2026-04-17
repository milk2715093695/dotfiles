Set-StrictMode -Version Latest

# 检查用户字体目录中是否存在 JetBrains Mono
function Test-UserJetBrainsMonoFont {
    Test-SoftwareAvailable -Key "font.jetbrains-mono"
}

# 使用 Scoop 安装用户级 JetBrains Mono 字体
function Install-JetBrainsMonoUserFont {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-UserJetBrainsMonoFont) {
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

Export-ModuleMember -Function Test-UserJetBrainsMonoFont, Install-JetBrainsMonoUserFont
