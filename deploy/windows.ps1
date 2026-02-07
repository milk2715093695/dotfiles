#!/usr/bin/env pwsh

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"     # 失败即退出

$global:SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path   # 脚本目录
$global:REPO_ROOT  = Resolve-Path "$SCRIPT_DIR\.."                     # 仓库目录

Import-Module   "$SCRIPT_DIR\windows\utils\Colors.psm1"     -Force  # 颜色
Import-Module   "$SCRIPT_DIR\windows\utils\Prompt.psm1"     -Force  # 提示函数
Import-Module   "$SCRIPT_DIR\windows\utils\Link.psm1"       -Force  # 链接函数
Import-Module   "$SCRIPT_DIR\windows\utils\GitHub.psm1"     -Force  # GitHub 操作
Import-Module   "$SCRIPT_DIR\windows\utils\Archive.psm1"    -Force  # 压缩包操作
Import-Module   "$SCRIPT_DIR\windows\utils\Shortcut.psm1"   -Force  # 快捷方式

Import-Module   "$SCRIPT_DIR\windows\packages\AltSnap.psm1"     -Force  # AltSnap
Import-Module   "$SCRIPT_DIR\windows\packages\JetBrains.psm1"   -Force  # JetBrains Mono
Import-Module   "$SCRIPT_DIR\windows\packages\WezTerm.psm1"     -Force  # WezTerm

Import-Module   "$SCRIPT_DIR\windows\Main.psm1"     -Force      # 主函数

Main
