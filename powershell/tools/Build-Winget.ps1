#Requires -Version 7.0
<#
.SYNOPSIS
    Emit winget.json from the Tools section of unixmap.psd1.

.DESCRIPTION
    winget.json is the Brewfile analogue: it declares what this SHELL
    CONFIGURATION needs, not what a given machine happens to have.

    That distinction is the whole design. `winget export` on BEAST returns 109
    packages — games, Adobe, drivers — which is a device inventory and belongs
    in the vault's device note, not in a public, cross-machine dotfiles repo.
    So this generates the manifest from unixmap.psd1 instead, keeping one
    source of truth and letting `winget import` work standalone for anyone who
    would rather not run bootstrap.ps1.

    Tools marked Install = $false are omitted, with `bat` the interesting case:
    BEAST already has it via Chocolatey under UniGetUI, and installing it again
    through winget would leave the box with two copies from two package
    managers.

.EXAMPLE
    pwsh -File tools/Build-Winget.ps1
#>
[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..' 'unixmap.psd1'),
    [string]$OutputPath   = (Join-Path $PSScriptRoot '..' 'winget.json')
)

$ErrorActionPreference = 'Stop'
$manifest = Import-PowerShellDataFile -LiteralPath $ManifestPath

$packages = $manifest.Tools |
    Where-Object { $_.Install } |
    Sort-Object { $_.WingetId } |
    ForEach-Object { [ordered]@{ PackageIdentifier = $_.WingetId } }

# Schema 2.0, matching what `winget export` produces on BEAST. No Version
# fields: pinning shell tooling to exact versions buys nothing and guarantees
# the manifest goes stale.
$doc = [ordered]@{
    '$schema'       = 'https://aka.ms/winget-packages.schema.2.0.json'
    CreationDate    = '2026-08-16T00:00:00.000-00:00'
    Sources         = @(
        [ordered]@{
            Packages      = @($packages)
            SourceDetails = [ordered]@{
                Argument             = 'https://cdn.winget.microsoft.com/cache'
                Identifier           = 'Microsoft.Winget.Source_8wekyb3d8bbwe'
                Name                 = 'winget'
                Type                 = 'Microsoft.PreIndexed.Package'
            }
        }
    )
    WinGetVersion   = '1.11.0'
}

# LF and no BOM, for the same reason as generated-aliases.ps1: identical inputs
# must give identical bytes whichever platform generated them.
$json = ($doc | ConvertTo-Json -Depth 6) -replace "`r`n", "`n"
[IO.File]::WriteAllText($OutputPath, $json + "`n", [System.Text.UTF8Encoding]::new($false))

[pscustomobject]@{
    Packages = @($packages).Count
    Omitted  = @($manifest.Tools | Where-Object { -not $_.Install }).Count
    Output   = $OutputPath
}
