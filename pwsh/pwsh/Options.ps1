# ====================================================
# =================== pwsh 历史选项 ===================
# ====================================================
Set-PSReadLineOption -HistorySavePath "$HOME\.pwsh_history" # 历史文件路径
Set-PSReadLineOption -MaximumHistoryCount 10000             # 历史条目数
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally    # 增量保存
Set-PSReadLineOption -HistoryNoDuplicates                   # 不保存重复条目
Set-PSReadLineOption -HistorySearchCursorMovesToEnd         # 搜索时光标移动到行尾

# ====================================================
# =================== 补全与提示选项 ===================
# ====================================================
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView

Set-PSReadLineOption -Colors @{
    Command = 'Green'
    String = 'Yellow'
    InlinePrediction = 'Cyan'
}
