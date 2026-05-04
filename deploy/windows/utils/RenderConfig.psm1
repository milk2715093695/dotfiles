Set-StrictMode -Version Latest

# 按需处理 # @locals:<file> 标记，将基础配置与 locals 拼接输出
#
# 与 deploy/posix/utils/render_config.sh 保持语义一致。
# 当基础配置中尚无 @locals: 标记时，直接复制（快路径）。
# 当基础配置引入标记后，逐行扫描并替换。
#
# 参数：
#   Source       基础配置文件路径
#   LocalsDir    locals 目录路径（可为不存在的目录）
#   Output       输出文件路径
#   CommentChar  注释符，默认 '#'
#
# 标记格式：
#   # @locals:<file>.<ext>
#
# 行为：
#   标记存在 + locals 文件存在   → 标记行被 locals 文件内容替换
#   标记存在 + locals 文件不存在 → 标记行被删除（空操作）
function Invoke-RenderConfigFile {
    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$LocalsDir,

        [Parameter(Mandatory)]
        [string]$Output,

        [string]$CommentChar = '#'
    )

    if (-not (Test-Path $Source -PathType Leaf)) {
        throw "基础配置文件不存在：$Source"
    }

    $outputDir = Split-Path $Output -Parent
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    # 快路径：无 @locals: 标记时直接复制
    $escapedComment = [regex]::Escape($CommentChar)
    $markerPattern = "${escapedComment}\s*@locals:"
    if (-not (Select-String -Path $Source -Pattern $markerPattern -Quiet)) {
        Copy-Item $Source $Output -Force
        return
    }

    # 逐行扫描，处理标记
    $markerRegex = "^\s*${escapedComment}\s*@locals:(.+)\s*$"
    $outputLines = [System.Collections.Generic.List[string]]::new()

    $sourceLines = Get-Content $Source
    foreach ($line in $sourceLines) {
        if ($line -match $markerRegex) {
            $refFile = $Matches[1].Trim()
            $fullPath = Join-Path $LocalsDir $refFile

            if (Test-Path $fullPath -PathType Leaf) {
                $localContent = Get-Content $fullPath -Raw
                $outputLines.Add($localContent)
            }
            # locals 文件不存在：删除标记行
        } else {
            $outputLines.Add($line)
        }
    }

    $outputText = $outputLines -join [Environment]::NewLine
    Set-Content -Path $Output -Value $outputText -NoNewline
}

Export-ModuleMember -Function Invoke-RenderConfigFile
