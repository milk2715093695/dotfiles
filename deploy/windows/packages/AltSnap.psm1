Set-StrictMode -Version Latest

$cpu = Get-CimInstance Win32_Processor

# 获取 AltSnap 的资产名字
function Get-AltSnapAssetName {
    param (
        [Parameter(Mandatory)]
        [string]$Version
    )

    if ($cpu.Architecture -eq 12) {
        return "AltSnap${Version}bin_ARM64.zip"
    }
    elseif ([Environment]::Is64BitOperatingSystem) {
        return "AltSnap${Version}bin_x64.zip"
    }
    else {
        return "AltSnap${Version}bin.zip"
    }
}

# 安装 AltSnap
function Install-AltSnap {
    $owner = "RamonUnch"
    $repo = "AltSnap"

    $version = Get-GitHubLatestReleaseTag -Owner $owner -Repo $repo

    Write-Host "AltSnap 最新版本: $version"

    if (-not (Read-Confirmation "是否需要更新或者安装 AltSnap？")) {
        Write-Host "跳过 AltSnap 的安装"
        return
    }

    $assetName = Get-AltSnapAssetName -Version $version

    $downloadedFile = Save-GitHubReleaseAsset `
        -Owner $owner `
        -Repo $repo `
        -Version $version `
        -AssetName $assetName `
        -OutputDir "$REPO_ROOT\cache"

    $unzipDir = "$REPO_ROOT\tools\AltSnap"

    Expand-ZipArchive -ZipPath $downloadedFile -Destination $unzipDir

    if (Read-Confirmation "是否创建桌面快捷方式？") {
        New-DesktopShortcut -TargetDir $unzipDir -ExecutableName "AltSnap.exe" -ShortcutName "AltSnap"
    }

    Write-WARNING "推荐自行添加开机启动项并运行，AltSnap 能帮助您拖动窗口"
}

Export-ModuleMember -Function Get-AltSnapAssetName, Install-AltSnap
