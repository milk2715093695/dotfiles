Set-StrictMode -Version Latest

# 交互选择配置冲突处理方式
function Read-ConfigAction {
    while ($true) {
        Write-Host "目标已存在，请选择配置处理方式："
        Write-Host "  b/B  备份一次 / 备份并对后续全部生效"
        Write-Host "  r/R  替换一次 / 替换并对后续全部生效"
        Write-Host "  l/L  只替换符号链接，文件或目录备份一次 / 对后续全部生效"
        Write-Host "  s/S  跳过一次 / 跳过并对后续全部生效"

        $answer = Read-Host "请输入选择 [b/B/r/R/l/L/s/S]"

        switch -CaseSensitive -Exact ($answer) {
            "b" { return "backup" }
            "B" {
                $global:CONFIG_MODE = "backup"
                return "backup"
            }
            "r" { return "replace" }
            "R" {
                $global:CONFIG_MODE = "replace"
                return "replace"
            }
            "l" { return "replace-link" }
            "L" {
                $global:CONFIG_MODE = "replace-link"
                return "replace-link"
            }
            "s" { return "skip" }
            "S" {
                $global:CONFIG_MODE = "skip"
                return "skip"
            }
            default {
                Write-Host "请输入 b/B/r/R/l/L/s/S。"
            }
        }
    }
}

# 根据配置解析本次处理方式
function Resolve-ConfigAction {
    $mode = $global:CONFIG_MODE
    if ([string]::IsNullOrWhiteSpace($mode)) {
        $mode = "ask"
    }

    switch ($mode) {
        "ask" { return (Read-ConfigAction) }
        "backup" { return "backup" }
        "replace" { return "replace" }
        "replace-link" { return "replace-link" }
        "skip" { return "skip" }
        default {
            Write-WARNING "未知配置模式 $mode，回退为交互模式。"
            return (Read-ConfigAction)
        }
    }
}

Export-ModuleMember -Function Read-ConfigAction, Resolve-ConfigAction
