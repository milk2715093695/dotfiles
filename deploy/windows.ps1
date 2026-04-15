#!/usr/bin/env pwsh

# 解析部署参数
param(
    [Alias("h", "?")]
    [switch]$Help,

    [switch]$YesInstall,

    [ValidateSet("ask", "backup", "replace", "replace-link", "skip")]
    [string]$ConfigMode = "ask"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"     # 失败即退出

$global:SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path   # 脚本目录
$global:REPO_ROOT  = Resolve-Path "$SCRIPT_DIR\.."                     # 仓库目录

# 打印部署脚本帮助
function Show-DeployUsage {
@"
用法: .\deploy\windows.ps1 [-YesInstall] [-ConfigMode ask|backup|replace|replace-link|skip] [-Help]

  -YesInstall          自动确认安装或更新类操作
  -ConfigMode MODE     配置冲突策略，默认 ask
  -Help, -h, -?        显示帮助信息

配置模式:
  ask           遇到已有目标时询问
  backup        备份已有符号链接、文件或目录后创建新链接
  replace       删除已有符号链接、文件或目录后创建新链接
  replace-link  替换符号链接，备份文件或目录
  skip          遇到已有目标时直接跳过
"@
}

if ($Help) {
    Show-DeployUsage
    exit 0
}

Import-Module   "$SCRIPT_DIR\windows\utils\DeployContext.psm1" -Force  # 部署上下文
Import-Module   "$SCRIPT_DIR\windows\utils\Colors.psm1"     -Force  # 颜色
Import-Module   "$SCRIPT_DIR\windows\utils\Prompt.psm1"     -Force  # 提示函数
Import-Module   "$SCRIPT_DIR\windows\utils\LinkAction.psm1" -Force  # 链接策略
Import-Module   "$SCRIPT_DIR\windows\utils\Link.psm1"       -Force  # 链接函数
Import-Module   "$SCRIPT_DIR\windows\utils\GitHub.psm1"     -Force  # GitHub 操作
Import-Module   "$SCRIPT_DIR\windows\utils\Archive.psm1"    -Force  # 压缩包操作
Import-Module   "$SCRIPT_DIR\windows\utils\Shortcut.psm1"   -Force  # 快捷方式
Import-Module   "$SCRIPT_DIR\windows\utils\Install.psm1"    -Force  # 安装
Import-Module   "$SCRIPT_DIR\windows\utils\PSGallery.psm1"  -Force  # PSGallery

Import-Module   "$SCRIPT_DIR\windows\packages\AltSnap.psm1"     -Force  # AltSnap
Import-Module   "$SCRIPT_DIR\windows\packages\JetBrains.psm1"   -Force  # JetBrains Mono
Import-Module   "$SCRIPT_DIR\windows\packages\WezTerm.psm1"     -Force  # WezTerm
Import-Module   "$SCRIPT_DIR\windows\packages\PWSH.psm1"        -Force  # PWSH
Import-Module   "$SCRIPT_DIR\windows\packages\PSFzf.psm1"       -Force  # PSFzf
Import-Module   "$SCRIPT_DIR\windows\packages\Starship.psm1"    -Force  # Starship
Import-Module   "$SCRIPT_DIR\windows\packages\Yazi.psm1"        -Force  # Yazi
Import-Module   "$SCRIPT_DIR\windows\packages\Cava.psm1"        -Force  # Cava
Import-Module   "$SCRIPT_DIR\windows\packages\LazyVim.psm1"     -Force  # LazyVim

Import-Module   "$SCRIPT_DIR\windows\Main.psm1"     -Force      # 主函数

# 执行部署入口
$deployContext = New-DeployContext -AutoInstall ([bool]$YesInstall) -ConfigMode $ConfigMode
Main -DeployContext $deployContext
