Set-StrictMode -Version Latest

# 渲染合并规则并生成 PAC 到 generated/pacproxy/
function Render-PacproxyAssets {
    $outDir = Join-Path $REPO_ROOT "generated\pacproxy"
    $officialDir = Join-Path $REPO_ROOT "pacproxy\gfw-pac"
    $userDir = Join-Path $REPO_ROOT "pacproxy\rules"

    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    Write-STEP "渲染 pacproxy 规则产物 -> $outDir"

    # 合并官方与用户规则，去重保序（UTF8 无 BOM，兼容 python 解析）
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false

    $direct = @(Get-Content (Join-Path $officialDir "direct-domains.txt"))
    if (Test-Path (Join-Path $userDir "direct-domains.txt")) {
        $direct += Get-Content (Join-Path $userDir "direct-domains.txt")
    }
    [IO.File]::WriteAllLines((Join-Path $outDir "direct-domains.txt"), ($direct | Select-Object -Unique), $utf8NoBom)

    $proxy = @(Get-Content (Join-Path $officialDir "proxy-domains.txt"))
    if (Test-Path (Join-Path $userDir "proxy-domains.txt")) {
        $proxy += Get-Content (Join-Path $userDir "proxy-domains.txt")
    }
    [IO.File]::WriteAllLines((Join-Path $outDir "proxy-domains.txt"), ($proxy | Select-Object -Unique), $utf8NoBom)

    Copy-Item (Join-Path $officialDir "local-tlds.txt") $outDir
    Copy-Item (Join-Path $officialDir "cidrs-cn.txt") $outDir

    # 生成 PAC：直接指向上游（透明转发），不再经 pacproxy 二次分流
    $python = (Get-Command python -ErrorAction Stop).Source
    & $python (Join-Path $officialDir "gfw-pac.py") -f (Join-Path $outDir "gfw.pac") `
        -p "PROXY 127.0.0.1:9910" `
        --proxy-domains (Join-Path $outDir "proxy-domains.txt") `
        --direct-domains (Join-Path $outDir "direct-domains.txt") `
        --localtld-domains (Join-Path $outDir "local-tlds.txt") `
        --ip-file (Join-Path $outDir "cidrs-cn.txt")
    if ($LASTEXITCODE -ne 0) { throw "gfw.pac 生成失败" }

    # 自包含：复制服务脚本，产物目录可独立运行
    Copy-Item (Join-Path $REPO_ROOT "pacproxy\pacproxy.py") $outDir

    if (-not (Test-Path (Join-Path $userDir "direct-domains.txt")) -or -not (Test-Path (Join-Path $userDir "proxy-domains.txt"))) {
        Write-WARNING "pacproxy\rules\ 缺少用户自定义规则（隐私文件，不入库）"
        Write-WARNING "参考 pacproxy\gfw-pac\direct-domains.txt 创建同名文件后重新部署"
    }
}

# 初始化 gfw-pac 规则子模块，渲染合并规则并生成 PAC
function Render-PacproxyTask {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    if (Test-Path (Join-Path $REPO_ROOT "pacproxy\gfw-pac\.git")) {
        Write-SKIP "gfw-pac 子模块已就位，跳过初始化"
    } else {
        Write-STEP "初始化 gfw-pac 规则子模块"
        Push-Location $REPO_ROOT
        try {
            git submodule update --init pacproxy/gfw-pac 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-WARNING "git submodule 注册不可用（尚未提交），改用 git clone 兜底"
                git clone --depth 1 https://github.com/zhiyi7/gfw-pac.git pacproxy/gfw-pac
            }
            if ($LASTEXITCODE -ne 0) { throw "gfw-pac 子模块初始化失败" }
        } finally {
            Pop-Location
        }
    }

    Render-PacproxyAssets
}

# 创建配置链接（符号链接失败时回退目录联接，SSH 过滤令牌场景）并注册计划任务
function New-PacproxyConfigLink {
    param(
        [Parameter(Mandatory)]
        [hashtable]$DeployContext
    )

    $target = Join-Path $HOME ".config\pacproxy"
    $source = Join-Path $REPO_ROOT "generated\pacproxy"

    if (-not (Test-TargetExists $target)) {
        $parent = Split-Path -Parent $target
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
        try {
            New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
            Write-SUCCESS "已创建符号链接：$target -> $source"
        } catch {
            Write-WARNING "符号链接需要管理员/开发者模式（当前为过滤令牌），回退为目录联接"
            New-Item -ItemType Junction -Path $target -Target $source | Out-Null
            Write-SUCCESS "已创建目录联接：$target -> $source"
        }
    } else {
        New-SymbolicLink -DeployContext $DeployContext -TargetPath $target -SourcePath $source
    }

    $python = (Get-Command python -ErrorAction Stop).Source
    $configDir = Join-Path $HOME ".config\pacproxy"
    $arguments = "$configDir\pacproxy.py --rules-dir $configDir --log $configDir\pacproxy.log"

    Register-AutostartTask `
        -DeployContext $DeployContext `
        -Name "pacproxy" `
        -Execute $python `
        -Argument $arguments `
        -Description "pacproxy 本地转发代理" `
        -RestartOnFailure
}

Export-ModuleMember -Function Test-PacproxyRuntime, Render-PacproxyTask, New-PacproxyConfigLink
