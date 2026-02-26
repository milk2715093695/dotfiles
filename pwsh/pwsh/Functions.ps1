# 配置代理的函数
function Set-Proxy {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("set","unset")]
        [string]$Action
    )

    # 默认参数
    $DefaultIP = "127.0.0.1"
    $DefaultHttpPort = "9910"
    $DefaultSocks5Port = "9909"

    # 取消代理
    if ($Action -eq "unset") {
        $vars = @(
            "SOCKS5_PROXY","HTTP_PROXY","HTTPS_PROXY","ALL_PROXY",
            "socks5_proxy","http_proxy","https_proxy","all_proxy"
        )

        foreach ($v in $vars) {
            Remove-Item Env:\$v -ErrorAction SilentlyContinue
        }

        Write-Output "代理环境变量已清空。"
        return
    }

    if ($Action -eq "set") {
        $ip = $DefaultIP
        $httpPort = $DefaultHttpPort
        $socks5Port = $DefaultSocks5Port
    }
    else {
        Write-Output "请输入代理信息（留空使用默认值）"

        $ip = Read-Host "代理 IP（默认 $DefaultIP）"
        if ([string]::IsNullOrWhiteSpace($ip)) { $ip = $DefaultIP }

        $httpPort = Read-Host "HTTP 端口（默认 $DefaultHttpPort）"
        if ([string]::IsNullOrWhiteSpace($httpPort)) { $httpPort = $DefaultHttpPort }

        $socks5Port = Read-Host "SOCKS5 端口（默认 $DefaultSocks5Port）"
        if ([string]::IsNullOrWhiteSpace($socks5Port)) { $socks5Port = $DefaultSocks5Port }
    }

    # 设置代理环境变量
    $env:SOCKS5_PROXY = "socks5h://${ip}:${socks5Port}"
    $env:HTTP_PROXY = "http://${ip}:${httpPort}"
    $env:HTTPS_PROXY = "http://${ip}:${httpPort}"
    $env:ALL_PROXY = "socks5h://${ip}:${socks5Port}"

    # 小写兼容
    $env:socks5_proxy = $env:SOCKS5_PROXY
    $env:http_proxy = $env:HTTP_PROXY
    $env:https_proxy = $env:HTTPS_PROXY
    $env:all_proxy = $env:ALL_PROXY

    Write-Output "代理环境变量已设置："
    Write-Output "SOCKS5_PROXY = $env:SOCKS5_PROXY"
    Write-Output "HTTP_PROXY   = $env:HTTP_PROXY"
    Write-Output "HTTPS_PROXY  = $env:HTTPS_PROXY"
    Write-Output "ALL_PROXY    = $env:ALL_PROXY"
}

# 懒加载密钥
function Import-Secrets {
    param (
        [string]$SecretsDir = "$HOME\.config\pwsh\Secrets"
    )

    if (-not (Test-Path $SecretsDir)) {
        Write-Host "目录 $SecretsDir 不存在" -ForegroundColor Red
        return
    }

    # 获取所有 ps1 文件
    $files = Get-ChildItem -Path $SecretsDir -Filter *.ps1

    if ($files.Count -eq 0) {
        Write-Host "没有找到 secrets 文件" -ForegroundColor Red
        return
    }

    Write-Host "可用 secrets 文件："
    for ($i = 0; $i -lt $files.Count; $i++) {
        Write-Host "[$($i+1)] $($files[$i].Name)"
    }
    Write-Host "[A] 加载全部"

    $choice = Read-Host "请输入编号或 A"

    if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $files.Count) {
        . $files[$choice - 1].FullName
        Write-Host "已加载 $($files[$choice - 1].Name)" -ForegroundColor Green
    } elseif ($choice -match '^[Aa]$') {
        foreach ($f in $files) {
            . $f.FullName
            Write-Host "已加载 $($f.Name)" -ForegroundColor Green
        }
    } else {
        Write-Host "无效输入" -ForegroundColor Red
    }
}
