Set-StrictMode -Version Latest

# 是否以管理员运行
function Test-WindowsAdministrator {
    if (-not $IsWindows) {
        return $false
    }

    $principal = [Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()

    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 部署入口
function Main {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (-not (Test-WindowsAdministrator)) {
        Write-WARNING "当前不是管理员权限运行。"
        Write-WARNING "如果未开启 Windows 开发者模式，创建符号链接可能失败。"
    }

    Initialize-DeployOutputView
    Test-SystemTools
    Test-PackageManagerAvailability

    $deployUnits = @(
        @{
            StageName = "安装 JetBrains 字体"
            Name = "JetBrains"
            AvailabilityCheck = ({ Test-UserJetBrainsMonoFont }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-JetBrainsMonoUserFont -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = $null
            Update = $null
            Tags = @("beauty", "dev")
        }
        @{
            StageName = "配置 WezTerm"
            Name = "WezTerm"
            AvailabilityCheck = ({ Test-WezTerm }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-WezTermPackage -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = ({ New-WezTermConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
            Tags = @("beauty", "dev")
        }
        @{
            StageName = "安装常用命令行工具"
            Name = "CLI Tools"
            AvailabilityCheck = ({ Test-CliToolSet }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-CliToolSet -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = $null
            Update = $null
            Tags = @("dev")
        }
        @{
            StageName = "配置 Starship"
            Name = "Starship"
            AvailabilityCheck = ({ Test-Starship }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-Starship -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = ({ New-StarshipConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
            Tags = @("beauty", "dev")
        }
        @{
            StageName = "配置 PowerShell"
            Name = "PWSH"
            AvailabilityCheck = $null
            Prepare = $null
            Install = $null
            Render = $null
            Link = ({ New-PwshConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = ({ Set-PwshOpenSshDefaultShell }).GetNewClosure()
            Tags = @("dev")
        }
        @{
            StageName = "安装 AltSnap"
            Name = "AltSnap"
            AvailabilityCheck = $null
            Prepare = $null
            Install = ({ Install-AltSnap -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = $null
            Update = $null
            Tags = @("dev")
        }
        @{
            StageName = "配置 Yazi"
            Name = "Yazi"
            AvailabilityCheck = ({ Test-Yazi }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-YaziRuntimeDependencies -DeployContext $DeployContext }).GetNewClosure()
            Render = ({ New-YaziRenderConfig }).GetNewClosure()
            Link = ({ New-YaziConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = ({ Install-OrUpdateYaziPackages -DeployContext $DeployContext }).GetNewClosure()
            Tags = @("beauty", "dev")
        }
        @{
            StageName = "配置 Cava"
            Name = "Cava"
            AvailabilityCheck = ({ Test-Cava }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-Cava -DeployContext $DeployContext }).GetNewClosure()
            Render = ({ New-CavaRenderConfig }).GetNewClosure()
            Link = ({ New-CavaConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
            Tags = @("beauty")
        }
        @{
            StageName = "配置 LazyVim"
            Name = "LazyVim"
            AvailabilityCheck = ({ Test-LazyVimRuntime }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-LazyVimRuntimeDependencies -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = ({ New-LazyVimConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
            Tags = @("beauty", "dev")
        }
        @{
            StageName = "配置 fastfetch"
            Name = "fastfetch"
            AvailabilityCheck = ({ Test-Fastfetch }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-Fastfetch -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = ({ New-FastfetchConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
            Tags = @("beauty")
        }
        @{
            StageName = "配置 gitlogue"
            Name = "gitlogue"
            AvailabilityCheck = ({ Test-Gitlogue }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-Gitlogue -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = ({ New-GitlogueConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
            Tags = @("beauty")
        }
        @{
            StageName = "配置 pacproxy 本地代理"
            Name = "pacproxy"
            AvailabilityCheck = ({ Test-PacproxyRuntime }).GetNewClosure()
            Prepare = $null
            Install = $null
            Render = ({ Render-PacproxyTask -DeployContext $DeployContext }).GetNewClosure()
            Link = ({ New-PacproxyConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
            Tags = @("dev")
        }
        @{
            StageName = "配置 aria2"
            Name = "aria2"
            AvailabilityCheck = ({ Test-Aria2 }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-Aria2 -DeployContext $DeployContext }).GetNewClosure()
            Render = ({ New-Aria2RenderConfig }).GetNewClosure()
            Link = ({ New-Aria2ConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
            Tags = @("dev")
        }
    )

    foreach ($unit in $deployUnits) {
        Invoke-DeployUnitStage -Unit $unit -DeployContext $DeployContext
    }

    Write-PLAIN ""
    Write-SUCCESS "部署完成。"
}

Export-ModuleMember -Function Main
