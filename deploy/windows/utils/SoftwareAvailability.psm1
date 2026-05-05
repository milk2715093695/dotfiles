Set-StrictMode -Version Latest

$script:SoftwareCommandByKey = @{
    "cli.fd" = "fd"
    "cli.fzf" = "fzf"
    "cli.zoxide" = "zoxide"
    "shell.starship" = "starship"
    "shell.fastfetch" = "fastfetch"
    "editor.neovim" = "nvim"
    "terminal.wezterm" = "wezterm"
    "filemanager.yazi" = "yazi"
    "audio.cava" = "cava"
}

$script:ScoopPackageBySoftwareKey = @{
    "cli.fd" = "fd"
    "cli.fzf" = "fzf"
    "cli.zoxide" = "zoxide"
    "shell.starship" = "starship"
    "shell.fastfetch" = "fastfetch"
    "terminal.wezterm" = "wezterm"
    "filemanager.yazi" = "yazi"
    "audio.cava" = "cava"
}

# 检查 canonical software key 对应的命令是否可用
function Test-SoftwareCommandAvailable {
    param(
        [Parameter(Mandatory)]
        [string]$Key
    )

    if (-not $script:SoftwareCommandByKey.ContainsKey($Key)) {
        return $false
    }

    return [bool](Get-Command $script:SoftwareCommandByKey[$Key] -ErrorAction SilentlyContinue)
}

# 检查 Scoop 记录是否能补充证明软件可用
function Test-ScoopSoftwareRecordAvailable {
    param(
        [Parameter(Mandatory)]
        [string]$Key
    )

    if (-not $script:ScoopPackageBySoftwareKey.ContainsKey($Key)) {
        return $false
    }

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        return $false
    }

    $packageName = $script:ScoopPackageBySoftwareKey[$Key]
    $pattern = "^\s*$([regex]::Escape($packageName))\s"
    $apps = scoop list 2>$null

    return [bool]($apps | Select-String -Pattern $pattern)
}

# 检查 canonical font key 是否可用
function Test-UserFontSoftwareAvailable {
    param(
        [Parameter(Mandatory)]
        [string]$Key
    )

    switch ($Key) {
        "font.jetbrains-mono" {
            $fontInstalled = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match "JetBrainsMono" }

            return [bool]$fontInstalled
        }
        default {
            return $false
        }
    }
}

# 检查 PowerShell 相关 canonical key 是否可用
function Test-PowerShellSoftwareAvailable {
    param(
        [Parameter(Mandatory)]
        [string]$Key
    )

    switch ($Key) {
        "powershell.psgallery" {
            if (-not (Get-Command Get-PSRepository -ErrorAction SilentlyContinue)) {
                return $false
            }

            $repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
            return [bool]$repo
        }
        default {
            return $false
        }
    }
}

# 检查 canonical software key 当前是否可用
function Test-SoftwareAvailable {
    param(
        [Parameter(Mandatory)]
        [string]$Key
    )

    if (Test-SoftwareCommandAvailable -Key $Key) {
        return $true
    }

    if (Test-UserFontSoftwareAvailable -Key $Key) {
        return $true
    }

    if (Test-PowerShellSoftwareAvailable -Key $Key) {
        return $true
    }

    if (Test-ScoopSoftwareRecordAvailable -Key $Key) {
        return $true
    }

    return $false
}

# 检查一组 canonical software key 是否全部可用
function Test-SoftwareSetAvailable {
    param(
        [Parameter(Mandatory)]
        [string[]]$Key
    )

    foreach ($softwareKey in $Key) {
        if (-not (Test-SoftwareAvailable -Key $softwareKey)) {
            return $false
        }
    }

    return $true
}

Export-ModuleMember -Function Test-SoftwareAvailable, Test-SoftwareSetAvailable
