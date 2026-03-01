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

# yazi 的包装器
function y {
	$tmp = (New-TemporaryFile).FullName
	yazi.exe $args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}
