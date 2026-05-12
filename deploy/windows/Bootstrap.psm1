Set-StrictMode -Version Latest

# 顶层导入：模块注册为嵌套模块，函数自然暴露
@(
    "$PSScriptRoot\utils\DeployContext.psm1"
    "$PSScriptRoot\utils\Colors.psm1"
    "$PSScriptRoot\utils\OutputView.psm1"
    "$PSScriptRoot\utils\DeployUnit.psm1"
    "$PSScriptRoot\utils\Prompt.psm1"
    "$PSScriptRoot\utils\LinkAction.psm1"
    "$PSScriptRoot\utils\Link.psm1"
    "$PSScriptRoot\utils\GitHub.psm1"
    "$PSScriptRoot\utils\Archive.psm1"
    "$PSScriptRoot\utils\Shortcut.psm1"
    "$PSScriptRoot\utils\SoftwareAvailability.psm1"
    "$PSScriptRoot\utils\PackageMapping.psm1"
    "$PSScriptRoot\utils\PackageManagerSelection.psm1"
    "$PSScriptRoot\utils\Install.psm1"
    "$PSScriptRoot\utils\RenderConfig.psm1"
    "$PSScriptRoot\utils\PSGallery.psm1"
    "$PSScriptRoot\utils\ToolCheck.psm1"
    "$PSScriptRoot\utils\Preset.psm1"
    "$PSScriptRoot\packages\AltSnap.psm1"
    "$PSScriptRoot\packages\JetBrains.psm1"
    "$PSScriptRoot\packages\WezTerm.psm1"
    "$PSScriptRoot\packages\PWSH.psm1"
    "$PSScriptRoot\packages\CliTools.psm1"
    "$PSScriptRoot\packages\Starship.psm1"
    "$PSScriptRoot\packages\Yazi.psm1"
    "$PSScriptRoot\packages\Cava.psm1"
    "$PSScriptRoot\packages\Fastfetch.psm1"
    "$PSScriptRoot\packages\LazyVim.psm1"
    "$PSScriptRoot\Main.psm1"
) | ForEach-Object { Import-Module $_ -Force }

# 打印部署脚本帮助
function Show-DeployUsage {
@"
用法: .\deploy\windows.ps1 [-YesInstall] [-ConfigMode ask|backup|replace|replace-link|skip] [-Preset PRESET] [-Skip UNIT,...] [-Only UNIT,...] [-Help]

  -YesInstall          自动确认安装或更新类操作
  -ConfigMode MODE     配置冲突策略，默认 ask
  -Preset PRESET       按预设过滤部署单元（beautification/beauty, development/dev）
                       逗号分隔多值，取并集
  -Skip UNIT,...       排除指定部署单元（逗号分隔，不区分大小写）
  -Only UNIT,...       仅部署指定单元（逗号分隔，不区分大小写；与 -Preset 互斥）
  -Help, -h, -?        显示帮助信息

配置模式:
  ask           遇到已有目标时询问
  backup        备份已有符号链接、文件或目录后创建新链接
  replace       删除已有符号链接、文件或目录后创建新链接
  replace-link  替换符号链接，备份文件或目录
  skip          遇到已有目标时直接跳过

示例:
  .\deploy\windows.ps1 -YesInstall -ConfigMode replace-link
  .\deploy\windows.ps1 -Preset beauty
  .\deploy\windows.ps1 -Preset dev -Skip Cava
  .\deploy\windows.ps1 -Only WezTerm,LazyVim
"@
}

# 导入 Windows deploy 所需模块
function Import-WindowsDeployModules {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptDir
    )

    $modulePaths = @(
        "$ScriptDir\windows\utils\DeployContext.psm1"
        "$ScriptDir\windows\utils\Colors.psm1"
        "$ScriptDir\windows\utils\OutputView.psm1"
        "$ScriptDir\windows\utils\DeployUnit.psm1"
        "$ScriptDir\windows\utils\Prompt.psm1"
        "$ScriptDir\windows\utils\LinkAction.psm1"
        "$ScriptDir\windows\utils\Link.psm1"
        "$ScriptDir\windows\utils\GitHub.psm1"
        "$ScriptDir\windows\utils\Archive.psm1"
        "$ScriptDir\windows\utils\Shortcut.psm1"
        "$ScriptDir\windows\utils\SoftwareAvailability.psm1"
        "$ScriptDir\windows\utils\PackageMapping.psm1"
        "$ScriptDir\windows\utils\PackageManagerSelection.psm1"
        "$ScriptDir\windows\utils\Install.psm1"
        "$ScriptDir\windows\utils\PSGallery.psm1"
        "$ScriptDir\windows\utils\ToolCheck.psm1"
        "$ScriptDir\windows\utils\Preset.psm1"
        "$ScriptDir\windows\packages\AltSnap.psm1"
        "$ScriptDir\windows\packages\JetBrains.psm1"
        "$ScriptDir\windows\packages\WezTerm.psm1"
        "$ScriptDir\windows\packages\PWSH.psm1"
        "$ScriptDir\windows\packages\CliTools.psm1"
        "$ScriptDir\windows\packages\Starship.psm1"
        "$ScriptDir\windows\packages\Yazi.psm1"
        "$ScriptDir\windows\packages\Cava.psm1"
        "$ScriptDir\windows\packages\Fastfetch.psm1"
        "$ScriptDir\windows\packages\LazyVim.psm1"
        "$ScriptDir\windows\Main.psm1"
    )

    foreach ($modulePath in $modulePaths) {
        Import-Module $modulePath -Force
    }
}

# 执行 Windows 部署入口
function Start-WindowsDeploy {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptDir,

        [Parameter(Mandatory)]
        [bool]$YesInstall,

        [Parameter(Mandatory)]
        [string]$ConfigMode,

        [Parameter(Mandatory)]
        [bool]$Help,

        [Parameter(Mandatory)]
        [string]$Preset,

        [Parameter(Mandatory)]
        [string]$SkipUnits,

        [Parameter(Mandatory)]
        [string]$OnlyUnits
    )

    if ($Help) {
        Show-DeployUsage
        return
    }

    $deployContext = New-DeployContext -AutoInstall $YesInstall -ConfigMode $ConfigMode `
        -Preset $Preset -SkipUnits $SkipUnits -OnlyUnits $OnlyUnits
    Main -DeployContext $deployContext
}
