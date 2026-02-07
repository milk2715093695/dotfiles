Set-StrictMode -Version Latest

# 创建符号链接函数
function New-SymbolicLink {
    param (
        [string]$TargetPath,   # 真实路径
        [string]$SourcePath    # 仓库路径
    )

    Write-Host "准备创建链接："
    Write-Host "    目标 (target)：$TargetPath -> 源 (source)：$SourcePath"
    Write-Host ""

    # 目标是符号链接
    if (Test-Path $TargetPath) {
        $item = Get-Item $TargetPath -ErrorAction SilentlyContinue
        if ($null -ne $item -and $item.LinkType) {
            Write-WARNING "注意：目标已经是一个符号链接。将删除旧链接并创建新的链接。"
            
            if (Read-Confirmation "确认要替换该符号链接吗？") {
                Remove-Item $TargetPath
                New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
                Write-Host "已替换符号链接：$TargetPath -> $SourcePath"
            } else {
                Write-Host "跳过：$TargetPath"
            }
            return
        }
    }

    # 目标存在
    if (Test-Path $TargetPath) {
        $item = Get-Item $TargetPath

        if ($item.PSIsContainer -and @(Get-ChildItem $TargetPath -Force).Count -eq 0) {
            Write-WARNING "注意：目标目录存在且为空。将删除该空目录并创建符号链接。"

            if (Read-Confirmation "确认要删除空目录并创建链接吗？") {
                Remove-Item $TargetPath
                New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
                Write-Host "已创建符号链接：$TargetPath -> $SourcePath"
            } else {
                Write-Host "跳过：$TargetPath"
            }
        } else {
            Write-ERROR "警告：目标已存在且非空（或不是目录）。"
            Write-Host "为避免数据丢失，将不会自动覆盖。"

            if (Read-Confirmation "确认要强制删除并替换为链接吗？") {
                Remove-Item $TargetPath -Recurse -Force
                New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
                Write-Host "已强制替换：$TargetPath -> $SourcePath"
            } else {
                Write-Host "跳过：$TargetPath"
            }
        }
        return
    }

    # 目标不存在
    if (Read-Confirmation "即将在 $TargetPath 创建符号链接") {
        New-Item -ItemType Directory -Force -Path (Split-Path $TargetPath) | Out-Null
        New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath | Out-Null
        Write-Host "已创建符号链接：$TargetPath -> $SourcePath"
    }
}

Export-ModuleMember -Function New-SymbolicLink
