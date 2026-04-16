Set-StrictMode -Version Latest

# 保证 PowerShell Gallery 仓库可用
function Initialize-PSGalleryRepository {
    $repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue

    if (-not $repo) {
        Write-WARNING "PSGallery 未找到。正在注册..."
        Register-PSRepository -Default
        Write-SUCCESS "PSGallery 已注册。"
    }
}

Export-ModuleMember -Function Initialize-PSGalleryRepository
