Set-StrictMode -Version Latest

# 检查 PSFzf 依赖是否存在
function Test-PSFzf {
    if (Get-Command "fzf" -ErrorAction SilentlyContinue) {
        return $true
    }

    return $false
}

Export-ModuleMember -Function Test-PSFzf
