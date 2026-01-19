#!/usr/bin/env pwsh

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"     # 失败即退出

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path   # 脚本目录
$REPO_ROOT = Resolve-Path "$SCRIPT_DIR\.."                      # 仓库目录

# 颜色定义
$YELLOW = "Yellow"
$RED    = "Red"
$GREEN  = "Green"

# 是否以管理员运行
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# CPU 架构
$cpu = Get-CimInstance Win32_Processor

# 交互函数
function Prompt-Confirm {
    param (
        [string]$Message
    )

    while ($true) {
        $answer = Read-Host "$Message [y/n]"
        switch -Regex ($answer) {
            '^[Yy]' { return $true }
            '^[Nn]' { return $false }
            default { Write-Host "Please answer y or n." }
        }
    }
}

# 创建符号链接函数
function Link-Dir {
    param (
        [string]$TargetPath,   # 真实路径
        [string]$SourcePath    # 仓库路径
    )

    Write-Host "准备创建链接："
    Write-Host "    目标 (target)：$TargetPath -> 源 (source)：$SourcePath"
    Write-Host ""

    # 目标是符号链接
    if (Test-Path $TargetPath) {
        $item = Get-Item $TargetPath -ErrorAction SilentlyContinue
        if ($null -ne $item -and $item.LinkType) {
            Write-Host "注意：目标已经是一个符号链接。将删除旧链接并创建新的链接。" -ForegroundColor $YELLOW

            if (Prompt-Confirm "确认要替换该符号链接吗？") {
                Remove-Item $TargetPath
                New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
                Write-Host "已替换符号链接：$TargetPath -> $SourcePath"
            } else {
                Write-Host "跳过：$TargetPath"
            }
            return
        }
    }

    # 目标存在
    if (Test-Path $TargetPath) {
        $item = Get-Item $TargetPath

        if ($item.PSIsContainer -and @(Get-ChildItem $TargetPath -Force).Count -eq 0) {
            Write-Host "注意：目标目录存在且为空。将删除该空目录并创建符号链接。" -ForegroundColor $YELLOW

            if (Prompt-Confirm "确认要删除空目录并创建链接吗？") {
                Remove-Item $TargetPath
                New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
                Write-Host "已创建符号链接：$TargetPath -> $SourcePath"
            } else {
                Write-Host "跳过：$TargetPath"
            }
        } else {
            Write-Host "警告：目标已存在且非空（或不是目录）。" -ForegroundColor $RED
            Write-Host "为避免数据丢失，将不会自动覆盖。"

            if (Prompt-Confirm "确认要强制删除并替换为链接吗？") {
                Remove-Item $TargetPath -Recurse -Force
                New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
                Write-Host "已强制替换：$TargetPath -> $SourcePath"
            } else {
                Write-Host "跳过：$TargetPath"
            }
        }
        return
    }

    # 目标不存在
    if (Prompt-Confirm "即将在 $TargetPath 创建符号链接") {
        New-Item -ItemType Directory -Force -Path (Split-Path $TargetPath) | Out-Null
        New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
        Write-Host "已创建符号链接：$TargetPath -> $SourcePath"
    }
}

# 获取最新的 Release 的 Tag
function Get-GitHubLatestReleaseTag {
    param (
        [Parameter(Mandatory)]
        [string]$Owner,

        [Parameter(Mandatory)]
        [string]$Repo
    )

    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/releases/latest"

    $headers = @{
        "User-Agent" = "PowerShell"
    }

    try {
        $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    } catch {
        throw "无法访问 GitHub API ($Owner/$Repo)：$($_.Exception.Message)"
    }

    if (-not $release.tag_name) {
        throw "未能从 GitHub API 获取 tag_name ($Owner/$Repo)"
    }

    return $release.tag_name
}

# 获取 AltSnap 的资产名字
function Get-AltSnapAssetName {
    param (
        [Parameter(Mandatory)]
        [string]$Version
    )

    if ($cpu.Architecture -eq 12) {
        return "AltSnap${Version}bin_ARM64.zip"
    }
    elseif ([Environment]::Is64BitOperatingSystem) {
        return "AltSnap${Version}bin_x64.zip"
    }
    else {
        return "AltSnap${Version}bin.zip"
    }
}

# 下载仓库 Release 到目录
function Download-GitHubReleaseAsset {
    param (
        [Parameter(Mandatory)]
        [string]$Owner,

        [Parameter(Mandatory)]
        [string]$Repo,

        [Parameter(Mandatory)]
        [string]$Version,

        [Parameter(Mandatory)]
        [string]$AssetName,

        [Parameter(Mandatory)]
        [string]$OutputDir
    )

    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }

    $downloadUrl = "https://github.com/$Owner/$Repo/releases/download/$Version/$AssetName"
    $outputPath = Join-Path $OutputDir $AssetName

    Write-Host "正在从 $downloadUrl 下载 $AssetName..."

    if (Test-Path $outputPath) {
        Write-Host "下载目标目录已经存在" -ForegroundColor $RED

        if (Prompt-Confirm "确认要强制删除并替换吗？") {
            Remove-Item $outputPath -Force
        } else {
            Write-Host "文件已存在: $outputPath" -ForegroundColor $YELLOW
            return $outputPath
        }
    }

    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath -UseBasicParsing
    } catch {
        throw "下载失败：$($_.Exception.Message)"
    }

    return $outputPath
}

# 解压 Zip
function Unzip-File {
    param (
        [Parameter(Mandatory)]
        [string]$ZipPath,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (-not (Test-Path $ZipPath)) {
        throw "Zip 文件不存在：$ZipPath"
    }

    if (Test-Path $Destination) {
        Write-Host "目标目录已经存在" -ForegroundColor $RED

        if (Prompt-Confirm "确认要强制删除并替换吗？") {
            Remove-Item $Destination -Recurse -Force
        } else {
            Write-Host "文件已存在: $Destination" -ForegroundColor $YELLOW
            return
        }
    }

    New-Item -ItemType Directory -Path $Destination | Out-Null

    Expand-Archive -Path $ZipPath -DestinationPath $Destination

    # 解压完成后删除压缩包
    Remove-Item -Path $ZipPath -Force
}

# 添加桌面快捷方式
function Create-DesktopShortcut {
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

    Write-Host "桌面快捷方式已创建：$desktopPath\$ShortcutName.lnk" -ForegroundColor $GREEN
}

# 安装 AltSnap
function Install-AltSnap {
    $owner = "RamonUnch"
    $repo = "AltSnap"

    $version = Get-GitHubLatestReleaseTag -Owner $owner -Repo $repo

    Write-Host "AltSnap 最新版本: $version"

    if (-not (Prompt-Confirm "是否需要更新或者安装 AltSnap？")) {
        Write-Host "跳过 AltSnap 的安装"
        return
    }

    $assetName = Get-AltSnapAssetName -Version $version

    $downloadedFile = Download-GitHubReleaseAsset `
        -Owner $owner `
        -Repo $repo `
        -Version $version `
        -AssetName $assetName `
        -OutputDir "$REPO_ROOT\cache"

    $unzipDir = "$REPO_ROOT\tools\AltSnap"

    Unzip-File -ZipPath $downloadedFile -Destination $unzipDir

    if (Prompt-Confirm "是否创建桌面快捷方式？") {
        Create-DesktopShortcut -TargetDir $unzipDir -ExecutableName "AltSnap.exe" -ShortcutName "AltSnap"
    }

    Write-Host "推荐自行添加开机启动项并运行，AltSnap 能帮助您拖动窗口" -ForegroundColor $YELLOW
}

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
        Write-Host "未安装 JetBrains Mono，但存在 scoop。" -ForegroundColor $YELLOW

        if (Prompt-Confirm "是否使用 scoop 安装 JetBrains Mono？") {
            scoop bucket add nerd-fonts
            scoop install jetbrains-mono
        } else {
            Write-Host "跳过字体安装。"
        }
        return
    }

    Write-Host "未检测到 scoop，无法自动安装 JetBrains Mono。" -ForegroundColor $YELLOW
    Write-Host "请手动安装字体，或自行扩展脚本。"
}

# 检查 WezTerm 是否存在
function Check-WezTerm {
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
function Install-WezTerm-Via-Scoop {
    Write-Host "未安装 wezterm，但存在 scoop。" -ForegroundColor $YELLOW

    if (Prompt-Confirm "是否使用 scoop 安装 wezterm？") {
        scoop install wezterm
    } else {
        Write-Host "跳过 wezterm 安装。"
    }
}

# 配置 WezTerm
function Configure-WezTerm {

    if (Check-WezTerm) {
        Write-Host "wezterm 已存在，跳过安装。"
    } else {
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Install-WezTerm-Via-Scoop
        } else {
            Write-Host "系统未安装 wezterm，且未检测到 scoop。" -ForegroundColor $YELLOW
            Write-Host "将跳过 wezterm 配置。"
        }
    }

    if (Check-WezTerm) {
        $target = "$env:USERPROFILE\.config\wezterm"
        $source = Join-Path $REPO_ROOT "wezterm"
        Link-Dir $target $source
    } else {
        Write-Host "没有 wezterm，跳过 wezterm 配置。" -ForegroundColor $YELLOW
    }
}

# 入口
function Main {
    Write-Host "================================"
    Write-Host " dotfiles deploy (Windows)"
    Write-Host "================================"
    Write-Host ""

    if (-not $IsAdmin) {
        Write-Host "当前不是管理员权限运行。" -ForegroundColor $YELLOW
        Write-Host "如果未开启 Windows 开发者模式，创建符号链接可能失败。"
    }

    Install-AltSnap

    Install-JetBrainsMono

    Configure-WezTerm

    Write-Host ""
    Write-Host "部署完成。" -ForegroundColor $GREEN
}

Main
