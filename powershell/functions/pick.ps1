# pick.ps1 — fzf for objects.
#
# PSFzf covers files and history, but both are TEXT pickers. Out-ConsoleGridView
# filters the OBJECTS already in the pipeline and returns the selection intact,
# so the result can be piped onward with its properties still attached. That is
# the thing fzf cannot do and the reason this is worth a wrapper.
#
# Interactive only: it draws a full-screen TUI and has nothing to draw on in a
# non-interactive session, so it is guarded.

if (-not (Get-Module -ListAvailable -Name Microsoft.PowerShell.ConsoleGuiTools)) { return }

function pick {
    <#
    .SYNOPSIS
        Interactively filter piped objects and return what you select.

    .EXAMPLE
        Get-Process | pick | Stop-Process -WhatIf
        Pick one process, keep it as an object, act on it.

    .EXAMPLE
        winhealth | Select-Object -ExpandProperty Volumes | pick -Multiple
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject,

        [string]$Title = 'pick',

        [switch]$Multiple
    )
    begin { $items = [System.Collections.Generic.List[object]]::new() }
    process { foreach ($i in $InputObject) { $items.Add($i) } }
    end {
        if (-not $items.Count) { return }
        if (-not $global:PSParityInteractive) {
            Write-Error 'pick needs an interactive session - it draws a TUI.'
            return
        }
        Import-Module Microsoft.PowerShell.ConsoleGuiTools
        $mode = if ($Multiple) { 'Multiple' } else { 'Single' }
        $items | Out-ConsoleGridView -Title $Title -OutputMode $mode
    }
}
