#!/usr/bin/env pwsh

# 解析部署参数
param(
    [Alias("h", "?")]
    [switch]$Help,

    [switch]$YesInstall,

    [ValidateSet("ask", "backup", "replace", "replace-link", "skip")]
    [string]$ConfigMode = "ask",

    [string]$Preset = "",

    [string]$Skip = "",

    [string]$Only = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"     # 失败即退出

$global:SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path    # 脚本目录
$global:REPO_ROOT  = Resolve-Path "$SCRIPT_DIR\.."                      # 仓库目录
$env:DEPLOY_PLATFORM = "windows"                                        # 部署平台

Import-Module "$SCRIPT_DIR\windows\Bootstrap.psm1" -Force  # 启动入口
Start-WindowsDeploy -ScriptDir $SCRIPT_DIR -YesInstall ([bool]$YesInstall) -ConfigMode $ConfigMode -Help ([bool]$Help) -Preset $Preset -SkipUnits $Skip -OnlyUnits $Only
