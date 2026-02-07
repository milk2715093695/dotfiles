Set-StrictMode -Version Latest

# 添加桌面快捷方式
function New-DesktopShortcut {
    param (
        [Parameter(Mandatory)]
        [string] $TargetDir,

        [Parameter(Mandatory)]
        [string] $ExecutableName,

        [string] $ShortcutName = $ExecutableName
    )

    $shell = New-Object -ComObject WScript.Shell
    $desktopPath = [Environment]::GetFolderPath("Desktop")

    $shortcut = $shell.CreateShortcut("$desktopPath\$ShortcutName.lnk")

    $targetPath = Join-Path $TargetDir $ExecutableName

    $shortcut.TargetPath = $targetPath
    $shortcut.WorkingDirectory = $TargetDir
    $shortcut.IconLocation = $targetPath
    $shortcut.Save()

    Write-INFO "桌面快捷方式已创建：$desktopPath\$ShortcutName.lnk"
}

Export-ModuleMember -Function New-DesktopShortcut
