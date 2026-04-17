Set-StrictMode -Version Latest

# 检查 PSFzf 依赖是否存在
function Test-PSFzf {
    Test-SoftwareAvailable -Key "cli.fzf"
}

Export-ModuleMember -Function Test-PSFzf
