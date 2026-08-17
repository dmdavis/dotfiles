# system.ps1 — df and du.
#
# Both return OBJECTS rather than formatted text, which is the PowerShell
# idiom and the whole reason the pipeline is worth learning: `df | Sort-Object
# FreeGB` works, where the GNU original would need awk.

function df {
    <#
    .SYNOPSIS
        Free space per filesystem drive, human-readable.
    #>
    Get-PSDrive -PSProvider FileSystem |
        Where-Object { $null -ne $_.Used -or $null -ne $_.Free } |
        ForEach-Object {
            $total = [double]$_.Used + [double]$_.Free
            [pscustomobject]@{
                Name     = $_.Name
                Root     = $_.Root
                UsedGB   = [math]::Round($_.Used / 1GB, 1)
                FreeGB   = [math]::Round($_.Free / 1GB, 1)
                TotalGB  = [math]::Round($total   / 1GB, 1)
                UsedPct  = if ($total -gt 0) { [math]::Round(100 * $_.Used / $total, 1) } else { $null }
            }
        }
}

function du {
    <#
    .SYNOPSIS
        Size of each immediate child of a path, largest first.
    .DESCRIPTION
        Slower than the GNU original — PowerShell has no stat cache and this
        walks every file. Fine for a project directory, painful on C:\.
    #>
    param([string]$Path = '.', [switch]$All)
    Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            $bytes = if ($_.PSIsContainer) {
                (Get-ChildItem -LiteralPath $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
                    Measure-Object -Property Length -Sum).Sum
            } else { $_.Length }
            [pscustomobject]@{
                Name  = $_.Name
                Type  = if ($_.PSIsContainer) { 'dir' } else { 'file' }
                SizeMB = [math]::Round(([double]$bytes) / 1MB, 2)
                Bytes = [long]$bytes
            }
        } |
        Where-Object { $All -or $_.Bytes -gt 0 } |
        Sort-Object Bytes -Descending
}
