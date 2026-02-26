# 兼容 Unix 风格的命令
Set-Alias python3 python -Scope Global

# 兼容 Unix 风格的 ll 命令
function ll {
    Get-ChildItem -Force | Format-Table -AutoSize
}

# 自动懒加载的 conda 函数
function conda {
    . "$HOME\.config\pwsh\Conda.ps1"
    Remove-Item Function:conda -ErrorAction SilentlyContinue
    & conda @Args
}
