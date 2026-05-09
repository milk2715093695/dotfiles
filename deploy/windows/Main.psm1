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

    $deployUnits = @(
        @{
            StageName = "安装 AltSnap"
            Name = "AltSnap"
            AvailabilityCheck = $null
            Prepare = $null
            Install = ({ Install-AltSnap -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = $null
            Update = $null
        }
        @{
            StageName = "安装 JetBrains Mono"
            Name = "JetBrains Mono"
            AvailabilityCheck = ({ Test-UserJetBrainsMonoFont }).GetNewClosure()
            Prepare = $null
            Install = ({ Install-JetBrainsMonoUserFont -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = $null
            Update = $null
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
        }
        @{
            StageName = "初始化 PSGallery"
            Name = "PSGallery"
            AvailabilityCheck = ({ Test-PSGalleryRepository }).GetNewClosure()
            Prepare = $null
            Install = ({ Register-PSGalleryRepository -DeployContext $DeployContext }).GetNewClosure()
            Render = $null
            Link = $null
            Update = $null
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
        }
        @{
            StageName = "配置 PowerShell"
            Name = "PowerShell"
            AvailabilityCheck = $null
            Prepare = ({ Set-PwshOpenSshDefaultShell }).GetNewClosure()
            Install = $null
            Render = $null
            Link = ({ New-PwshConfigLink -DeployContext $DeployContext }).GetNewClosure()
            Update = $null
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
        }
    )

    foreach ($unit in $deployUnits) {
        Invoke-DeployUnitStage -Unit $unit
    }

    Write-PLAIN ""
    Write-SUCCESS "部署完成。"
}

Export-ModuleMember -Function Main
