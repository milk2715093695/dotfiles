Set-StrictMode -Version Latest

# 检查 Windows MSVC 构建工具链是否可用
function Test-WindowsBuildToolchain {
    if (-not $IsWindows) {
        return $true
    }

    $hasCl = [bool](Get-Command cl.exe -ErrorAction SilentlyContinue)
    $hasLink = [bool](Get-Command link.exe -ErrorAction SilentlyContinue)

    if (-not $hasCl -or -not $hasLink) {
        Write-WARNING "未检测到 Visual Studio Build Tools（cl.exe / link.exe）。"
        Write-WARNING "gitlogue 通过 cargo 从源码编译，需要 MSVC 工具链。"
        Write-WARNING "请安装 Visual Studio Build Tools（选择'使用 C++ 的桌面开发'工作负载）。"
        Write-WARNING "下载地址：https://visualstudio.microsoft.com/visual-cpp-build-tools/"
    }
}

# 检查 gitlogue 是否可用
function Test-Gitlogue {
    Test-SoftwareAvailable -Key "cli.gitlogue"
}

# 安装 gitlogue
function Install-Gitlogue {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Test-WindowsBuildToolchain

    Install-SoftwareKey -DeployContext $DeployContext -Key "cli.gitlogue"

    if (Read-InstallConfirmation -DeployContext $DeployContext -Message "是否使用 cargo 安装 gitlogue？") {
        Write-STEP "编译并安装 gitlogue"
        $env:Path = "$HOME\.cargo\bin;$env:Path"
        cargo install gitlogue
        Persist-GitloguePath
    }
    else {
        Write-SKIP "跳过 gitlogue 安装"
    }
}

# 尝试将 ~\.cargo\bin 持久化写入 PowerShell 配置
function Persist-GitloguePath {
    $funcDefined = try {
        (Get-Content "$HOME\.config\pwsh\Functions.ps1" -Raw) -match 'function\s+Add-PersistentPath\b'
    }
    catch { $false }

    if ($funcDefined) {
        . "$HOME\.config\pwsh\Functions.ps1"
        Add-PersistentPath "$HOME\.cargo\bin" -Local
        Write-SKIP "已注册到 Locals/Env.ps1"
    }
    else {
        Write-WARNING "gitlogue 已编译安装，但未持久化到 PowerShell 配置。"
        Write-WARNING "请手动将以下行添加到 PowerShell 配置中："
        Write-WARNING '  $env:Path = "$HOME\.cargo\bin;$env:Path"'
    }
}

# 创建 gitlogue 配置链接
function New-GitlogueConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = "$HOME\.config\gitlogue"
    $source = "$REPO_ROOT\gitlogue"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
}

Export-ModuleMember -Function Test-Gitlogue, Install-Gitlogue, New-GitlogueConfigLink
