Set-StrictMode -Version Latest

# 配置 PSFzf
function Initialize-PSFzf {
    if (Get-Command "fzf" -ErrorAction SilentlyContinue) {
        
    } else {
        Write-Warning "fzf 未安装，跳过 PSFzf 初始化"
    }
}

Export-ModuleMember -Function Initialize-PSFzf
