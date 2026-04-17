Set-StrictMode -Version Latest

# 检查 PowerShell Gallery 仓库是否可用
function Test-PSGalleryRepository {
    Test-SoftwareAvailable -Key "powershell.psgallery"
}

# 注册 PowerShell Gallery 仓库
function Register-PSGalleryRepository {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-PSGalleryRepository) {
        Write-SKIP "PSGallery 已注册。"
        return
    }

    Write-WARNING "PSGallery 未找到。"

    if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否注册 PSGallery？") {
        Write-STEP "注册 PSGallery"
        Register-PSRepository -Default
        Write-SUCCESS "PSGallery 已注册。"
    } else {
        Write-SKIP "跳过 PSGallery 注册。"
    }
}

Export-ModuleMember -Function Test-PSGalleryRepository, Register-PSGalleryRepository
