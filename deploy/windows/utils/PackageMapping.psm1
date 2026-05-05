Set-StrictMode -Version Latest

$script:PackageSpecsByManagerAndKey = @{
    "scoop:cli.fd" = @(
        @{ Kind = "package"; Name = "fd" }
    )
    "scoop:cli.fzf" = @(
        @{ Kind = "package"; Name = "fzf" }
    )
    "scoop:cli.zoxide" = @(
        @{ Kind = "package"; Name = "zoxide" }
    )
    "scoop:shell.starship" = @(
        @{ Kind = "package"; Name = "starship" }
    )
    "scoop:shell.fastfetch" = @(
        @{ Kind = "package"; Name = "fastfetch" }
    )
    "scoop:editor.neovim" = @(
        @{ Kind = "package"; Name = "neovim" }
        @{ Kind = "package"; Name = "python" }
        @{ Kind = "package"; Name = "nodejs" }
        @{ Kind = "package"; Name = "fd" }
    )
    "scoop:terminal.wezterm" = @(
        @{ Kind = "package"; Name = "wezterm" }
    )
    "scoop:filemanager.yazi" = @(
        @{ Kind = "package"; Name = "yazi" }
        @{ Kind = "package"; Name = "ffmpeg" }
        @{ Kind = "package"; Name = "7zip" }
        @{ Kind = "package"; Name = "jq" }
        @{ Kind = "package"; Name = "poppler" }
        @{ Kind = "package"; Name = "fd" }
        @{ Kind = "package"; Name = "ripgrep" }
        @{ Kind = "package"; Name = "fzf" }
        @{ Kind = "package"; Name = "zoxide" }
        @{ Kind = "package"; Name = "resvg" }
        @{ Kind = "package"; Name = "imagemagick" }
        @{ Kind = "package"; Name = "clipboard" }
        @{ Kind = "package"; Name = "bat" }
        @{ Kind = "package"; Name = "less" }
        @{ Kind = "package"; Name = "glow" }
        @{ Kind = "package"; Name = "file" }
    )
    "scoop:audio.cava" = @(
        @{ Kind = "package"; Name = "cava" }
    )
    "scoop:font.jetbrains-mono" = @(
        @{ Kind = "bucket"; Name = "nerd-fonts" }
        @{ Kind = "package"; Name = "jetbrains-mono" }
    )

    "winget:shell.starship" = @(
        @{ Kind = "package"; Name = "Starship.Starship" }
    )
    "winget:shell.fastfetch" = @(
        @{ Kind = "package"; Name = "fastfetch" }
    )
    "winget:editor.neovim" = @(
        @{ Kind = "package"; Name = "Neovim.Neovim" }
    )
    "winget:terminal.wezterm" = @(
        @{ Kind = "package"; Name = "WezTerm.WezTerm" }
    )
}

# Return install specs for a canonical software key on a package manager.
function Get-PackageInstallSpec {
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Manager
    )

    $mapKey = "$($Manager):$($Key)"
    if (-not $script:PackageSpecsByManagerAndKey.ContainsKey($mapKey)) {
        return @()
    }

    return $script:PackageSpecsByManagerAndKey[$mapKey] | ForEach-Object {
        [pscustomobject]@{
            Manager = $Manager
            Kind = $_.Kind
            Name = $_.Name
        }
    }
}

Export-ModuleMember -Function Get-PackageInstallSpec
