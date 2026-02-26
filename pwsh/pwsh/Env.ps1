# 用于增加 PATH 同时防止环境变量重复添加的函数
function Add-PathEntry {
    param(
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$PathEntry
    )

    foreach ($dir in $PathEntry) {
        if (Test-Path -Path $dir -PathType Container) {
            $currentPaths = $env:PATH -split ';'

            if ($currentPaths -notcontains $dir) {

                $env:PATH = "$dir;$env:PATH"
                Write-Host "目录 $dir 被添加到 PATH 中"

            }

        } 
        else {
            Write-Host "错误：目录 $dir 不存在"
        }
    }
}
# 由于 windows 的 PATH 其实是自动管理的，因此基本上用不到这个函数

# 用于增加模块路径的函数
function Add-ModulePath {
    param(
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$ModulePath
    )

    foreach ($dir in $ModulePath) {

        # 检查路径是否存在
        if (Test-Path -Path $dir -PathType Container) {

            # 获取当前的模块路径列表
            $currentPaths = $env:PSModulePath -split ';'

            # 如果还没有这个路径，则添加
            if ($currentPaths -notcontains $dir) {
                $env:PSModulePath = "$dir;$env:PSModulePath"
                Write-Host "目录 $dir 被添加到 PSModulePath 中"
            } else {
                Write-Host "目录 $dir 已经存在于 PSModulePath 中"
            }

        } else {
            Write-Host "错误：目录 $dir 不存在"
        }
    }
}
