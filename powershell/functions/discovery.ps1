# discovery.ps1 — grep and alias search.

if (Get-Command rg -ErrorAction SilentlyContinue) {
    # Windows has no grep. findstr is not a substitute — different regex
    # dialect, no recursive default, no colour.
    function grep { rg @args }
}

function alg {
    <#
    .SYNOPSIS
        Search aliases AND functions by name or definition.
    .DESCRIPTION
        The zsh original was `alias | rg`. This searches functions too, which
        matters here because most of the zsh alias set had to become functions
        — PowerShell aliases cannot carry arguments, so `alias | rg` would miss
        almost everything that was ported.
    #>
    param([Parameter(Mandatory)][string]$Pattern)
    Get-Command -CommandType Alias, Function -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match $Pattern -or $_.Definition -match $Pattern } |
        Sort-Object Name |
        Select-Object @{ N = 'Name'; E = { $_.Name } },
                      @{ N = 'Kind'; E = { $_.CommandType } },
                      @{ N = 'Definition'; E = { ($_.Definition -replace '\s+', ' ').Trim() } }
}
