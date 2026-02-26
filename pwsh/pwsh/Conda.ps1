# 自动生成的 conda 配置
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\mac\scoop\apps\anaconda3\current\App\Scripts\conda.exe") {
    (& "C:\Users\mac\scoop\apps\anaconda3\current\App\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion
