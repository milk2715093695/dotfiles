# starship 初始化
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
}

# zoxide 初始化
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression ((zoxide init powershell) -join "`n")
}

# fzf 初始化
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf

    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'       # 绑定 Ctrl+t 为模糊搜索
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' # 绑定 Ctrl+r 为反向历史搜索

    # 配置 fzf 使用 fd
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = "fd --type f"
    }
}
