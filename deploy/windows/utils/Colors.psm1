Set-StrictMode -Version Latest

# 颜色定义
$script:GREEN  = "Green"
$script:YELLOW = "Yellow"
$script:RED    = "Red"

function Write-INFO {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host $Message -ForegroundColor $script:GREEN
}

function Write-WARNING {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host $Message -ForegroundColor $script:YELLOW
}

function Write-ERROR {
    param (
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host $Message -ForegroundColor $script:RED
}

Export-ModuleMember -Function Write-INFO, Write-WARNING, Write-ERROR
