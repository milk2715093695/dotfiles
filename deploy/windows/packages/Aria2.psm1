Set-StrictMode -Version Latest

# 检查 aria2 是否可用
function Test-Aria2 {
    Test-SoftwareAvailable -Key "cli.aria2"
}

# 安装 aria2
function Install-Aria2 {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    Install-SoftwareKey -DeployContext $DeployContext -Key "cli.aria2"
}

# 渲染 aria2 配置：处理 @locals 覆盖（下载目录等）
function New-Aria2RenderConfig {
    Write-STEP "渲染 aria2 配置"

    $generatedDir = Join-Path $REPO_ROOT "generated\aria2"
    New-Item -ItemType Directory -Path $generatedDir -Force | Out-Null

    # rpc-secret 缺失时不写入（保持模板删标记行为），仅提示
    $secretFile = Join-Path $REPO_ROOT "aria2\locals\rpc-secret.conf"
    if (-not (Test-Path $secretFile -PathType Leaf)) {
        Write-WARNING "aria2 RPC secret 未配置（aria2/locals/rpc-secret.conf 缺失）"
        Write-WARNING "RPC 将无 token 运行；如需保护请创建该文件（内容形如 rpc-secret=<值>）"
    }

    # session 目录预创建（aria2 不自动建父目录，首次启动需存在；放 render 保证每次执行）
    $sessionDir = Join-Path $HOME ".local\state\aria2"
    New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null
    $sessionFile = Join-Path $sessionDir "aria2.session"
    if (-not (Test-Path $sessionFile -PathType Leaf)) {
        New-Item -ItemType File -Path $sessionFile -Force | Out-Null
    }

    Invoke-RenderConfigFile `
        -Source (Join-Path $REPO_ROOT "aria2\aria2.conf") `
        -Output (Join-Path $generatedDir "aria2.conf")

    # 下载目录预创建（aria2 不自动建父目录）：取渲染产物最后一个 dir= 行展开 ${HOME}
    $rendered = Join-Path $generatedDir "aria2.conf"
    $dirLine = (Get-Content $rendered | Where-Object { $_ -match '^dir=' } | Select-Object -Last 1)
    if ($dirLine) {
        $downloadDir = ($dirLine -split '=', 2)[1].Replace('${HOME}', $HOME)
        if ($downloadDir) {
            New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
        }
    }
}

# 创建 aria2 配置链接（整目录链接，与 fastfetch/gitlogue 等惯例一致），并注册开机自启（autostart 通用层）
function New-Aria2ConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = Join-Path $HOME ".config\aria2"
    $source = Join-Path $REPO_ROOT "generated\aria2"
    New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source

    $aria2c = (Get-Command aria2c -ErrorAction SilentlyContinue).Source
    if ([string]::IsNullOrWhiteSpace($aria2c)) {
        Write-WARNING "未找到 aria2c，跳过 aria2 启动项注册"
        return
    }
    $configFile = Join-Path $HOME ".config\aria2\aria2.conf"
    Register-AutostartTask `
        -DeployContext $DeployContext `
        -Name "aria2" `
        -Execute $aria2c `
        -Argument "--conf-path=$configFile" `
        -Description "aria2 下载器"
}

Export-ModuleMember -Function Test-Aria2, Install-Aria2, New-Aria2RenderConfig, New-Aria2ConfigLink
