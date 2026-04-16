Set-StrictMode -Version Latest

# 保证 PowerShell Gallery 仓库可用
function Initialize-PSGalleryRepository {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue

    if (-not $repo) {
        Write-WARNING "PSGallery 未找到。"

        if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否注册 PSGallery？") {
            Write-STEP "注册 PSGallery"
            Register-PSRepository -Default
            Write-SUCCESS "PSGallery 已注册。"
        } else {
            Write-SKIP "跳过 PSGallery 注册。"
        }
    }
}

Export-ModuleMember -Function Initialize-PSGalleryRepository
