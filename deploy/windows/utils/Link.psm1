Set-StrictMode -Version Latest

# 判断目标是否存在
function Test-TargetExists {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        return $true
    }

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    return ($null -ne $item)
}

# 判断目标是否为符号链接
function Test-SymbolicLink {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    return ($null -ne $item -and -not [string]::IsNullOrEmpty($item.LinkType))
}

# 判断目标链接是否已经指向源路径
function Test-SameSymbolicLink {
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath,

        [Parameter(Mandatory)]
        [string]$SourcePath
    )

    if (-not (Test-SymbolicLink $TargetPath)) {
        return $false
    }

    $item = Get-Item -LiteralPath $TargetPath -Force
    $linkTarget = @($item.Target) -join ""

    if ($linkTarget -eq $SourcePath) {
        return $true
    }

    try {
        $targetResolved = (Resolve-Path -LiteralPath $TargetPath).ProviderPath
        $sourceResolved = (Resolve-Path -LiteralPath $SourcePath).ProviderPath
        return [string]::Equals($targetResolved, $sourceResolved, [StringComparison]::OrdinalIgnoreCase)
    } catch {
        return $false
    }
}

# 生成不冲突的备份路径
function Get-BackupPath {
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath
    )

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $basePath = "$TargetPath.bak.$timestamp"
    $backupPath = $basePath
    $index = 1

    while (Test-TargetExists $backupPath) {
        $backupPath = "$basePath.$index"
        $index++
    }

    return $backupPath
}

# 备份已有目标
function Backup-Target {
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath
    )

    $backupPath = Get-BackupPath $TargetPath
    Move-Item -LiteralPath $TargetPath -Destination $backupPath
    Write-Host "已备份：$TargetPath -> $backupPath"
}

# 删除已有目标
function Remove-Target {
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath
    )

    Remove-Item -LiteralPath $TargetPath -Recurse -Force
    Write-Host "已删除：$TargetPath"
}

# 创建符号链接
function New-Link {
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath,

        [Parameter(Mandatory)]
        [string]$SourcePath
    )

    $parent = Split-Path -Parent $TargetPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
    Write-Host "已创建符号链接：$TargetPath -> $SourcePath"
}

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

# 创建或更新符号链接
function New-SymbolicLink {
    param (
        [string]$TargetPath,
        [string]$SourcePath
    )

    # 先处理已正确链接的情况，避免重复删除或备份
    Write-Host "准备创建链接："
    Write-Host "    目标 (target)：$TargetPath -> 源 (source)：$SourcePath"
    Write-Host ""

    if (Test-SameSymbolicLink -TargetPath $TargetPath -SourcePath $SourcePath) {
        Write-Host "目标已经是指向同一源的符号链接，跳过：$TargetPath"
        return
    }

    if (Test-TargetExists $TargetPath) {
        $action = Resolve-ConfigAction

        # replace-link 只替换旧链接，普通文件和目录仍保留为备份
        switch ($action) {
            "backup" {
                Backup-Target $TargetPath
                New-Link -TargetPath $TargetPath -SourcePath $SourcePath
            }
            "replace" {
                Remove-Target $TargetPath
                New-Link -TargetPath $TargetPath -SourcePath $SourcePath
            }
            "replace-link" {
                if (Test-SymbolicLink $TargetPath) {
                    Remove-Target $TargetPath
                } else {
                    Backup-Target $TargetPath
                }
                New-Link -TargetPath $TargetPath -SourcePath $SourcePath
            }
            "skip" {
                Write-Host "跳过：$TargetPath"
            }
        }
        return
    }

    New-Link -TargetPath $TargetPath -SourcePath $SourcePath
}

Export-ModuleMember -Function New-SymbolicLink
