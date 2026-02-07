Set-StrictMode -Version Latest

# 解压 Zip
function Expand-ZipArchive {
    param (
        [Parameter(Mandatory)]
        [string]$ZipPath,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (-not (Test-Path $ZipPath)) {
        throw "Zip 文件不存在：$ZipPath"
    }

    if (Test-Path $Destination) {
        Write-ERROR "目标目录已经存在"

        if (Read-Confirmation "确认要强制删除并替换吗？") {
            Remove-Item $Destination -Recurse -Force
        } else {
            Write-WARNING "文件已存在: $Destination"
            return
        }
    }

    New-Item -ItemType Directory -Path $Destination | Out-Null

    Expand-Archive -Path $ZipPath -DestinationPath $Destination

    # 解压完成后删除压缩包
    Remove-Item -Path $ZipPath -Force
}

Export-ModuleMember -Function Expand-ZipArchive
