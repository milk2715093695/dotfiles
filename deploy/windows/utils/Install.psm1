Set-StrictMode -Version Latest

# 使用 Scoop 安装包
function Install-ScoopPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter()]
        [switch]$App  # 如果指定，则使用 scoop install --app (等价于 brew cask)
    )

    # 检查是否已安装
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Host "$Name 已安装 (命令可用)"
        return
    }

    if ($App) {
        if (scoop list | Select-String -Pattern "^$Name\s") {
            Write-Host "$Name 已安装 (Scoop app)"
            return
        }
    } else {
        if (scoop list | Select-String -Pattern "^$Name\s") {
            Write-Host "$Name 已安装 (Scoop bucket)"
            return
        }
    }

    # 提示安装
    if (Read-Confirmation "是否使用 Scoop 安装 $Name？") {
        $installArgs = @("install")
        if ($App) { $installArgs += "--app" }
        $installArgs += $Name

        Write-Host "使用 Scoop 安装 $Name..."
        scoop @installArgs
    } else {
        Write-Host "跳过 $Name 安装"
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

            if (Read-Confirmation "是否使用 Chocolatey 安装 $Name？") {
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

            if (Read-Confirmation "是否使用 winget 安装 $Name？") {
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
