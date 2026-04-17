Set-StrictMode -Version Latest

$script:PackageManagerPriority = @("scoop", "winget")

# Return package manager priority for Windows deploy.
function Get-PackageManagerPriority {
    return $script:PackageManagerPriority
}

# Check whether a package manager is available on this machine.
function Test-PackageManagerAvailable {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("scoop", "winget")]
        [string]$Manager
    )

    return [bool](Get-Command $Manager -ErrorAction SilentlyContinue)
}

Export-ModuleMember -Function Get-PackageManagerPriority, Test-PackageManagerAvailable
