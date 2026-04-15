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

# 创建或更新符号链接
function New-SymbolicLink {
    param (
        [Parameter(Mandatory)]
        [hashtable]$DeployContext,

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
        $action = Resolve-ConfigAction -DeployContext $DeployContext

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
