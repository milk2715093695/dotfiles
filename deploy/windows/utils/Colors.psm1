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
        [string]$Color
    )

    $content = "[$Label] $Message"
    if (Test-ColorEnabled) {
        Write-Host $content -ForegroundColor $Color
    } else {
        Write-Host $content
    }
}

function Write-STEP {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "STEP" -Message $Message -Color $script:CYAN
}

function Write-INFO {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "INFO" -Message $Message -Color $script:BLUE
}

function Write-SUCCESS {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "OK" -Message $Message -Color $script:GREEN
}

function Write-SKIP {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "SKIP" -Message $Message -Color $script:YELLOW
}

function Write-WARNING {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "WARN" -Message $Message -Color $script:YELLOW
}

function Write-ERROR {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Label -Label "ERROR" -Message $Message -Color $script:RED
}

Export-ModuleMember -Function Write-STEP, Write-INFO, Write-SUCCESS, Write-SKIP, Write-WARNING, Write-ERROR
