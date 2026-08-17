# core.ps1 — always loaded, interactive or not.
#
# CONTRACT: this file must never write to stdout. No Write-Host, no bare
# expressions, no cmdlet left unassigned. See the comment in profile.ps1 for
# what breaks when that slips.

# --- environment ---------------------------------------------------------
# (PATH additions and env vars go here — nothing yet.)

# Collected rather than printed: a load failure must not write to stdout here.
# interactive.ps1 surfaces it, and Test-PSParity reports it in any session.
$global:PSParityLoadErrors = @()

# --- what gets loaded, in order ------------------------------------------
# generated-aliases.ps1 first (Phase C2, emitted from `zsh -ic alias` on the
# Mac and committed — not produced at load time), then the hand-written shims.
$toLoad = @()
$generated = Join-Path $PSScriptRoot 'generated-aliases.ps1'
if (Test-Path -LiteralPath $generated) { $toLoad += $generated }

$fnDir = Join-Path $PSScriptRoot 'functions'
if (Test-Path -LiteralPath $fnDir) {
    $toLoad += (Get-ChildItem -LiteralPath $fnDir -Filter '*.ps1' -File |
        Sort-Object Name | Select-Object -ExpandProperty FullName)
}

# Two things this loop is careful about, both learned the hard way:
#
#   1. It is a `foreach` STATEMENT, not ForEach-Object, and the dot-source is
#      inline rather than wrapped in a helper function. Dot-sourcing inside a
#      pipeline or a function puts the definitions in that scope, where they
#      evaporate on exit. Only an inline dot-source in a dot-sourced file
#      reaches global.
#   2. Files are parsed before they are run. A syntax error in a dot-sourced
#      file aborts the entire profile — one bad hashtable in functions/ left
#      the shell with no config at all and a stack trace on every command.
#      Parsing first turns that into one skipped file. try/catch still wraps
#      the dot-source for errors that only appear at runtime.
foreach ($file in $toLoad) {
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $file, [ref]$null, [ref]$parseErrors)

    if ($parseErrors) {
        $global:PSParityLoadErrors += [pscustomobject]@{
            File  = Split-Path $file -Leaf
            Stage = 'parse'
            Error = ($parseErrors | ForEach-Object { $_.Message }) -join '; '
        }
        continue
    }

    try {
        . $file
    } catch {
        $global:PSParityLoadErrors += [pscustomobject]@{
            File  = Split-Path $file -Leaf
            Stage = 'run'
            Error = $_.Exception.Message
        }
    }
}
