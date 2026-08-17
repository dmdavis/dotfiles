# core.ps1 — always loaded, interactive or not.
#
# CONTRACT: this file must never write to stdout. No Write-Host, no bare
# expressions, no cmdlet left unassigned. See the comment in profile.ps1 for
# what breaks when that slips.

# --- environment ---------------------------------------------------------
# (PATH additions and env vars go here — nothing yet.)

# --- generated aliases (Phase C2) ----------------------------------------
# Emitted from `zsh -ic alias` on the Mac via the generator; committed, not
# produced at load time.
$generated = Join-Path $PSScriptRoot 'generated-aliases.ps1'
if (Test-Path -LiteralPath $generated) { . $generated }

# --- hand-written shims --------------------------------------------------
# NOTE: `foreach` statement, not `ForEach-Object`. Dot-sourcing inside a
# pipeline puts the definitions in the pipeline's scope, where they evaporate
# the moment it ends. The foreach *statement* runs in the current scope.
$fnDir = Join-Path $PSScriptRoot 'functions'
if (Test-Path -LiteralPath $fnDir) {
    foreach ($f in Get-ChildItem -LiteralPath $fnDir -Filter '*.ps1' -File) {
        . $f.FullName
    }
}
