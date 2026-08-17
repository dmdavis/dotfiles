# legacy-shims.ps1
#
# Lifted verbatim from BEAST's machine-local Microsoft.PowerShell_profile.ps1
# (last edited 2024-03-28) when that file was replaced by the $PROFILE stub.
# Kept as-is so nothing is lost in the move; Phase C2 replaces these with
# generated equivalents driven by unixmap.psd1.
#
# Known rough edges, deliberately preserved rather than fixed here:
#   - `ll` is an alias pointing at another alias (`ls`), which is not the same
#     thing as `ls -lh` and was flagged as such in the original.
#   - `which` shells out to where.exe rather than using Get-Command, so it
#     misses functions, aliases and cmdlets.

New-Alias -Name 'll' -Value 'ls' -ErrorAction SilentlyContinue

function printenvOnPowershell { Get-ChildItem env: }
New-Alias -Name 'printenv' -Value 'printenvOnPowershell' -ErrorAction SilentlyContinue

function touchOnPowershell {
    $file = $args[0]
    if ($null -eq $file) {
        throw "No filename supplied"
    }
    if (Test-Path $file) {
        (Get-ChildItem $file).LastWriteTime = Get-Date
    } else {
        $null > $file
    }
}
New-Alias -Name 'touch' -Value 'touchOnPowershell' -ErrorAction SilentlyContinue

function which { where.exe $args }

# --- kubectl -------------------------------------------------------------
New-Alias -Name 'kc' -Value 'kubectl' -ErrorAction SilentlyContinue
function kcgp { kubectl get pods $args }
function kcgd { kubectl get deployments $args }
