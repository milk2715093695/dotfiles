Set-StrictMode -Version Latest

# 使用 Scoop 安装包
function Install-ScoopPackage {
    [CmdletBinding()]
    param(
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
                Write-Host "$pkg 已安装 (命令可用)"
                continue
            }

            if (scoop list | Select-String -Pattern "^$pkg\s") {
                Write-Host "$pkg 已安装 (Scoop)"
                continue
            }

            # 安装类确认统一走 Read-InstallConfirmation，避免影响其他交互
            # 询问是否安装
            if (Read-InstallConfirmation "是否使用 Scoop 安装 $pkg？") {

                $installArgs = @("install")
                if ($App) { $installArgs += "--app" }
                $installArgs += $pkg

                Write-Host "使用 Scoop 安装 $pkg..."
                scoop @installArgs
            }
            else {
                Write-Host "跳过 $pkg 安装"
            }
        }
    }
}

# 通用包管理器安装函数
function Install-PackageByManager {
    [CmdletBinding()]
    param(
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
                Write-Error "未找到 Scoop，请先安装 Scoop。"
                return
            }
            Install-ScoopPackage -Name $Name -App:$App
        }
        'choco' {
            if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
                Write-Error "未找到 Chocolatey，请先安装 Chocolatey。"
                return
            }

            # 检查是否安装
            $installed = choco list --local-only | Select-String -Pattern "^$Name\s"
            if ($installed) {
                Write-Host "$Name 已安装 (Chocolatey)"
                return
            }

            # Chocolatey 和 winget 也复用安装类确认逻辑
            if (Read-InstallConfirmation "是否使用 Chocolatey 安装 $Name？") {
                choco install $Name -y
            } else {
                Write-Host "跳过 $Name 安装"
            }
        }
        'winget' {
            if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
                Write-Error "未找到 winget，请先安装 winget。"
                return
            }

            # winget 没有简单方法判断已安装，这里尝试查询
            $installed = winget list --name $Name | Select-String -Pattern $Name
            if ($installed) {
                Write-Host "$Name 已安装 (winget)"
                return
            }

            if (Read-InstallConfirmation "是否使用 winget 安装 $Name？") {
                winget install --id $Name --accept-package-agreements --accept-source-agreements
            } else {
                Write-Host "跳过 $Name 安装"
            }
        }
        default {
            Write-Error "未知包管理器: $Manager"
        }
    }
}

Export-ModuleMember -Function Install-ScoopPackage, Install-PackageByManager
