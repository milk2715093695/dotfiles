Set-StrictMode -Version Latest

# 安装 JetBrains Mono 字体
function Install-JetBrainsMono {
    # 如果已安装，跳过
    $fontInstalled = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "JetBrainsMono" }

    if ($fontInstalled) {
        Write-Host "JetBrains Mono 已安装，跳过字体安装。"
        return
    }

    # 仅支持 scoop
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-WARNING "未安装 JetBrains Mono，但存在 scoop。"

        if (Read-Confirmation "是否使用 scoop 安装 JetBrains Mono？") {
            scoop bucket add nerd-fonts
            scoop install jetbrains-mono
        } else {
            Write-Host "跳过字体安装。"
        }
        return
    }

    Write-WARNING "未检测到 scoop，无法自动安装 JetBrains Mono。"
    Write-Host "请手动安装字体，或自行扩展脚本。"
}

Export-ModuleMember -Function Install-JetBrainsMono
