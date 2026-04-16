Set-StrictMode -Version Latest

# 交互选择配置冲突处理方式
function Read-ConfigAction {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    while ($true) {
        Write-PLAIN -Message "目标已存在，请选择配置处理方式：" -Stream stderr
        Write-PLAIN -Message "  b/B  备份一次 / 备份并对后续全部生效" -Stream stderr
        Write-PLAIN -Message "  r/R  替换一次 / 替换并对后续全部生效" -Stream stderr
        Write-PLAIN -Message "  l/L  只替换符号链接，文件或目录备份一次 / 对后续全部生效" -Stream stderr
        Write-PLAIN -Message "  s/S  跳过一次 / 跳过并对后续全部生效" -Stream stderr

        $answer = Read-Host "请输入选择 [b/B/r/R/l/L/s/S]:"

        switch -CaseSensitive -Exact ($answer) {
            "b" { return "backup" }
            "B" {
                Set-DeployConfigMode -DeployContext $DeployContext -ConfigMode "backup"
                return "backup"
            }
            "r" { return "replace" }
            "R" {
                Set-DeployConfigMode -DeployContext $DeployContext -ConfigMode "replace"
                return "replace"
            }
            "l" { return "replace-link" }
            "L" {
                Set-DeployConfigMode -DeployContext $DeployContext -ConfigMode "replace-link"
                return "replace-link"
            }
            "s" { return "skip" }
            "S" {
                Set-DeployConfigMode -DeployContext $DeployContext -ConfigMode "skip"
                return "skip"
            }
            default {
                Write-WARNING "请输入 b/B/r/R/l/L/s/S。"
            }
        }
    }
}

# 根据配置解析本次处理方式
function Resolve-ConfigAction {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $mode = Get-DeployConfigMode -DeployContext $DeployContext

    switch ($mode) {
        "ask" { return (Read-ConfigAction -DeployContext $DeployContext) }
        "backup" { return "backup" }
        "replace" { return "replace" }
        "replace-link" { return "replace-link" }
        "skip" { return "skip" }
        default {
            Write-WARNING "未知配置模式 $mode，回退为交互模式。"
            return (Read-ConfigAction -DeployContext $DeployContext)
        }
    }
}

Export-ModuleMember -Function Read-ConfigAction, Resolve-ConfigAction
