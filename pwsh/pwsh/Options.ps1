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
    Command = '#a6da95'
    Parameter = '#f5a97f'
    String = '#eed49f'
    Variable = '#cad3f5'
    Comment = '#5b6078'
    Operator = '#ed8796'
    InlinePrediction = '#c6a0f6'
    Number = '#cad3f5'
    Type = '#a6da95'
    Keyword = '#a6da95'
}
