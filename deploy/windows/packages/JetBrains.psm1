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

    Install-SoftwareKey -DeployContext $DeployContext -Key "font.jetbrains-mono"
}

Export-ModuleMember -Function Test-UserJetBrainsMonoFont, Install-JetBrainsMonoUserFont
