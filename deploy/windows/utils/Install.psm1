Set-StrictMode -Version Latest

# 使用 Scoop 安装包
function Install-ScoopPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$DeployContext,

        # 支持多个包名
        [
            Parameter(
                Mandatory=$true,
                Position=0,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
            )
        ]
        [string[]]$Name,

        [Parameter()]
        [switch]$App
    )

    process {
        foreach ($pkg in $Name) {

            # 检查是否已安装
            if (Get-Command $pkg -ErrorAction SilentlyContinue) {
                Write-SKIP "$pkg 已安装 (命令可用)"
                continue
            }

            if (scoop list | Select-String -Pattern "^$pkg\s") {
                Write-SKIP "$pkg 已安装 (Scoop)"
                continue
            }

            # 安装类确认统一走 Read-InstallConfirmation，避免影响其他交互
            # 询问是否安装
            if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否使用 Scoop 安装 $pkg？") {

                $installArgs = @("install")
                if ($App) { $installArgs += "--app" }
                $installArgs += $pkg

                Write-STEP "使用 Scoop 安装 $pkg"
                scoop @installArgs
            }
            else {
                Write-SKIP "跳过 $pkg 安装"
            }
        }
    }
}

# 通过指定包管理器安装包
function Install-PackageByManager {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$DeployContext,

        [Parameter(Mandatory=$true)]
        [ValidateSet('scoop','choco','winget')]
        [string]$Manager,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter()]
        [switch]$App  # 对于 scoop，是否使用 app
    )

    switch ($Manager) {
        'scoop' {
            if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
                Write-ERROR "未找到 Scoop，请先安装 Scoop。"
                return
            }
            Install-ScoopPackage -DeployContext $DeployContext -Name $Name -App:$App
        }
        'choco' {
            if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
                Write-ERROR "未找到 Chocolatey，请先安装 Chocolatey。"
                return
            }

            # 检查是否安装
            $installed = choco list --local-only | Select-String -Pattern "^$Name\s"
            if ($installed) {
                Write-SKIP "$Name 已安装 (Chocolatey)"
                return
            }

            # Chocolatey 和 winget 也复用安装类确认逻辑
            if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否使用 Chocolatey 安装 $Name？") {
                Write-STEP "使用 Chocolatey 安装 $Name"
                choco install $Name -y
            } else {
                Write-SKIP "跳过 $Name 安装"
            }
        }
        'winget' {
            if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
                Write-ERROR "未找到 winget，请先安装 winget。"
                return
            }

            # winget 使用包 ID 安装，优先按 ID 查询现有记录。
            $installed = winget list --id $Name | Select-String -Pattern ([regex]::Escape($Name))
            if ($installed) {
                Write-SKIP "$Name 已安装 (winget)"
                return
            }

            if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否使用 winget 安装 $Name？") {
                Write-STEP "使用 winget 安装 $Name"
                winget install --id $Name --accept-package-agreements --accept-source-agreements
            } else {
                Write-SKIP "跳过 $Name 安装"
            }
        }
        default {
            Write-ERROR "未知包管理器: $Manager"
        }
    }
}

# 安装一条 manager-specific install spec
function Install-PackageInstallSpec {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext,

        [Parameter(Mandatory)]
        [pscustomobject]$Spec
    )

    switch ($Spec.Manager) {
        "scoop" {
            switch ($Spec.Kind) {
                "bucket" {
                    if (scoop bucket list | Select-String -Pattern "^$([regex]::Escape($Spec.Name))\s") {
                        Write-SKIP "$($Spec.Name) bucket 已存在。"
                        return
                    }

                    if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否添加 Scoop bucket $($Spec.Name)？") {
                        Write-STEP "添加 Scoop bucket $($Spec.Name)"
                        scoop bucket add $Spec.Name
                    } else {
                        Write-SKIP "跳过 Scoop bucket $($Spec.Name)。"
                    }
                }
                "package" {
                    Install-ScoopPackage -DeployContext $DeployContext -Name $Spec.Name
                }
                default {
                    Write-WARNING "未知 Scoop install spec 类型：$($Spec.Kind)"
                }
            }
        }
        "winget" {
            if ($Spec.Kind -ne "package") {
                Write-WARNING "winget 不支持 install spec 类型：$($Spec.Kind)"
                return
            }

            Install-PackageByManager -DeployContext $DeployContext -Manager winget -Name $Spec.Name
        }
        default {
            Write-WARNING "未知包管理器：$($Spec.Manager)"
        }
    }
}

# 根据 canonical software key 选择可用 manager 并安装
function Install-SoftwareKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext,

        [Parameter(Mandatory)]
        [string]$Key
    )

    if (Test-SoftwareAvailable -Key $Key) {
        Write-SKIP "$Key 已可用"
        return
    }

    foreach ($manager in Get-PackageManagerPriority) {
        if (-not (Test-PackageManagerAvailable -Manager $manager)) {
            continue
        }

        $specs = @(Get-PackageInstallSpec -Key $Key -Manager $manager)
        if ($specs.Count -eq 0) {
            continue
        }

        Write-STEP "选择 $manager 安装 $Key"
        foreach ($spec in $specs) {
            Install-PackageInstallSpec -DeployContext $DeployContext -Spec $spec
        }
        return
    }

    Write-WARNING "没有可用包管理器支持安装 $Key，请手动安装。"
}

# 安装一组 canonical software key
function Install-SoftwareSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext,

        [Parameter(Mandatory)]
        [string[]]$Key
    )

    foreach ($softwareKey in $Key) {
        Install-SoftwareKey -DeployContext $DeployContext -Key $softwareKey
    }
}

Export-ModuleMember -Function Install-ScoopPackage, Install-PackageByManager, Install-PackageInstallSpec, Install-SoftwareKey, Install-SoftwareSet
