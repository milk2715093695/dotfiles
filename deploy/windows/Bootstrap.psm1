Set-StrictMode -Version Latest

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
        "$ScriptDir\windows\utils\Install.psm1"
        "$ScriptDir\windows\utils\PSGallery.psm1"
        "$ScriptDir\windows\packages\AltSnap.psm1"
        "$ScriptDir\windows\packages\JetBrains.psm1"
        "$ScriptDir\windows\packages\WezTerm.psm1"
        "$ScriptDir\windows\packages\PWSH.psm1"
        "$ScriptDir\windows\packages\PSFzf.psm1"
        "$ScriptDir\windows\packages\CliTools.psm1"
        "$ScriptDir\windows\packages\Starship.psm1"
        "$ScriptDir\windows\packages\Yazi.psm1"
        "$ScriptDir\windows\packages\Cava.psm1"
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
        [bool]$Help
    )

    if ($Help) {
        Show-DeployUsage
        return
    }

    Import-WindowsDeployModules -ScriptDir $ScriptDir

    $deployContext = New-DeployContext -AutoInstall $YesInstall -ConfigMode $ConfigMode
    Main -DeployContext $deployContext
}

Export-ModuleMember -Function Show-DeployUsage, Import-WindowsDeployModules, Start-WindowsDeploy
