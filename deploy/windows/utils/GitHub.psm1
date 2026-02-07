Set-StrictMode -Version Latest

# 获取最新的 Release 的 Tag
function Get-GitHubLatestReleaseTag {
    param (
        [Parameter(Mandatory)]
        [string]$Owner,

        [Parameter(Mandatory)]
        [string]$Repo
    )

    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/releases/latest"

    $headers = @{
        "User-Agent" = "PowerShell"
    }

    try {
        $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    } catch {
        throw "无法访问 GitHub API ($Owner/$Repo)：$($_.Exception.Message)"
    }

    if (-not $release.tag_name) {
        throw "未能从 GitHub API 获取 tag_name ($Owner/$Repo)"
    }

    return $release.tag_name
}

# 下载仓库 Release 到目录
function Save-GitHubReleaseAsset {
    param (
        [Parameter(Mandatory)]
        [string]$Owner,

        [Parameter(Mandatory)]
        [string]$Repo,

        [Parameter(Mandatory)]
        [string]$Version,

        [Parameter(Mandatory)]
        [string]$AssetName,

        [Parameter(Mandatory)]
        [string]$OutputDir
    )

    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }

    $downloadUrl = "https://github.com/$Owner/$Repo/releases/download/$Version/$AssetName"
    $outputPath = Join-Path $OutputDir $AssetName

    Write-Host "正在从 $downloadUrl 下载 $AssetName..."

    if (Test-Path $outputPath) {
        Write-ERROR "下载目标目录已经存在"

        if (Read-Confirmation "确认要强制删除并替换吗？") {
            Remove-Item $outputPath -Force
        } else {
            Write-WARNING "文件已存在: $outputPath"
            return $outputPath
        }
    }

    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath -UseBasicParsing
    } catch {
        throw "下载失败：$($_.Exception.Message)"
    }

    return $outputPath
}

Export-ModuleMember -Function Get-GitHubLatestReleaseTag, Save-GitHubReleaseAsset
