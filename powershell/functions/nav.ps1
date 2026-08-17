# nav.ps1 — navigation shims.

function mkcd {
    <#
    .SYNOPSIS
        Create a directory and change into it, as in zsh.
    #>
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location -LiteralPath $Path
}
