Set-StrictMode -Version Latest

# 颜色定义
$script:CYAN   = "Cyan"
$script:BLUE   = "Blue"
$script:GREEN  = "Green"
$script:YELLOW = "Yellow"
$script:RED    = "Red"

# 判断是否启用颜色输出
function Test-ColorEnabled {
    return [string]::IsNullOrWhiteSpace($env:NO_COLOR)
}

# 输出带标签的消息
function Write-Label {
    param (
        [Parameter(Mandatory)]
        [string]$Label,

        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter(Mandatory)]
        [string]$Color,

        [ValidateSet("stdout", "stderr")]
        [string]$Stream = "stdout"
    )

    $content = "[$Label] $Message"
    if ($Stream -eq "stderr") {
        [Console]::Error.WriteLine($content)
        return
    }

    if (Test-ColorEnabled) {
        Write-Host $content -ForegroundColor $Color
    } else {
        Write-Host $content
    }
}

# 输出普通消息
function Write-PLAIN {
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Message,

        [ValidateSet("stdout", "stderr")]
        [string]$Stream = "stdout"
    )

    if ($Stream -eq "stderr") {
        [Console]::Error.WriteLine($Message)
    } else {
        Write-Host $Message
    }
}

# 输出步骤消息
function Write-STEP {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "STEP" -Message $Message -Color $script:CYAN
}

# 输出信息消息
function Write-INFO {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "INFO" -Message $Message -Color $script:BLUE
}

# 输出成功消息
function Write-SUCCESS {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "OK" -Message $Message -Color $script:GREEN
}

# 输出跳过消息
function Write-SKIP {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "SKIP" -Message $Message -Color $script:YELLOW
}

# 输出警告消息
function Write-WARNING {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "WARN" -Message $Message -Color $script:YELLOW -Stream stderr
}

# 输出错误消息
function Write-ERROR {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "ERROR" -Message $Message -Color $script:RED -Stream stderr
}

Export-ModuleMember -Function Write-PLAIN, Write-STEP, Write-INFO, Write-SUCCESS, Write-SKIP, Write-WARNING, Write-ERROR
