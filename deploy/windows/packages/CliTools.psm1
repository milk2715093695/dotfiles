Set-StrictMode -Version Latest

$script:CliToolSetSoftwareKeys = @("cli.fd", "cli.fzf", "cli.zoxide")

# 检查常用命令行工具是否存在
function Test-CliToolSet {
    Test-SoftwareSetAvailable -Key $script:CliToolSetSoftwareKeys
}

# 安装常用命令行工具
function Install-CliToolSet {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-SoftwareSet -DeployContext $DeployContext -Key $script:CliToolSetSoftwareKeys
}

Export-ModuleMember -Function Test-CliToolSet, Install-CliToolSet
