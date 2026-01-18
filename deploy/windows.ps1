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

    Configure-WezTerm

    Write-Host ""
    Write-Host "部署完成。" -ForegroundColor $GREEN
}

Main
