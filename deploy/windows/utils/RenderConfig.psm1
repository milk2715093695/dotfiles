Set-StrictMode -Version Latest

# 按需处理 # @platform:<file> 和 # @locals:<file> 标记，将基础配置拼接输出
#
# 与 deploy/posix/utils/render_config.sh 保持语义一致。
# 当基础配置中尚无标记时，直接复制（快路径）。
# 当基础配置引入标记后，逐行扫描并替换。
#
# 参数：
#   Source       基础配置文件路径
#   Output       输出文件路径
#   CommentChar  注释符，默认 '#'
#
# 内部推导：
#   ToolDir      = Split-Path $Source -Parent         -- 工具根目录
#   PlatformDir  = $ToolDir/$env:DEPLOY_PLATFORM       -- 平台目录（tracked）
#   LocalsDir    = $ToolDir/locals                     -- 本地覆盖目录（gitignored）
#
# 标记格式：
#   # @platform:<file>.<ext>
#   # @locals:<file>.<ext>
#
# 行为：
#   标记存在 + 对应文件存在   → 标记行被文件内容替换
#   标记存在 + 对应文件不存在 → 标记行被删除（空操作）
function Invoke-RenderConfigFile {
    param(
        [Parameter(Mandatory)]
        [string]$Source,

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

    $ToolDir = Split-Path $Source -Parent
    $PlatformDir = Join-Path $ToolDir $env:DEPLOY_PLATFORM
    $LocalsDir = Join-Path $ToolDir "locals"

    # 快路径：无标记时直接复制
    $escapedComment = [regex]::Escape($CommentChar)
    $platformPattern = "${escapedComment}\s*@platform:"
    $localsPattern = "${escapedComment}\s*@locals:"
    $hasPlatform = Select-String -Path $Source -Pattern $platformPattern -Quiet
    $hasLocals = Select-String -Path $Source -Pattern $localsPattern -Quiet
    if (-not $hasPlatform -and -not $hasLocals) {
        Copy-Item $Source $Output -Force
        return
    }

    # 逐行扫描，处理 @platform: 和 @locals: 标记
    $platformRegex = "^\s*${escapedComment}\s*@platform:(.+)\s*$"
    $localsRegex = "^\s*${escapedComment}\s*@locals:(.+)\s*$"
    $outputLines = [System.Collections.Generic.List[string]]::new()

    $sourceLines = Get-Content $Source
    foreach ($line in $sourceLines) {
        if ($line -match $platformRegex) {
            $refFile = $Matches[1].Trim()
            $fullPath = Join-Path $PlatformDir $refFile

            if (Test-Path $fullPath -PathType Leaf) {
                $content = Get-Content $fullPath -Raw
                $outputLines.Add($content)
            }
            # 文件不存在：删除标记行
        } elseif ($line -match $localsRegex) {
            $refFile = $Matches[1].Trim()
            $fullPath = Join-Path $LocalsDir $refFile

            if (Test-Path $fullPath -PathType Leaf) {
                $content = Get-Content $fullPath -Raw
                $outputLines.Add($content)
            }
            # 文件不存在：删除标记行
        } else {
            $outputLines.Add($line)
        }
    }

    $outputText = $outputLines -join [Environment]::NewLine
    Set-Content -Path $Output -Value $outputText -NoNewline
}

Export-ModuleMember -Function Invoke-RenderConfigFile
