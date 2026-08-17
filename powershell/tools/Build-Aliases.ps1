#Requires -Version 7.0
<#
.SYNOPSIS
    Emit generated-aliases.ps1 from a zsh alias dump plus unixmap.psd1.

.DESCRIPTION
    Reads the dump produced by tools/dump-aliases.zsh on the Mac, classifies
    every entry against unixmap.psd1, translates the tier-A entries into
    PowerShell, and writes a committed generated-aliases.ps1.

    Three things this deliberately does NOT do:

      * It does not run at shell start. The output is committed, so a broken
        generator cannot break the shell, and the diff is reviewable.
      * It does not guess collisions. It asks the running PowerShell which
        aliases already exist, because the answer is version-dependent and
        because command lookup is case-INSENSITIVE — `Gl` and the built-in
        `gl` are the same name, which no amount of reading the manifest
        reveals.
      * It does not emit anything it cannot translate. Entries using POSIX-only
        tools or unhandled shell constructs are skipped and reported by name
        and reason, never silently dropped.

    Everything is compared case-SENSITIVELY. Zim's git grammar distinguishes
    GSx (git-submodule-remove) from Gsx (git stash drop); see the Matching
    section of unixmap.psd1.

.EXAMPLE
    ./Build-Aliases.ps1 -ReportOnly
    Show what would be emitted, write nothing.

.EXAMPLE
    ./Build-Aliases.ps1
    Regenerate ../generated-aliases.ps1.
#>
[CmdletBinding()]
param(
    [string]$DumpPath     = (Join-Path $PSScriptRoot '..' 'zsh-aliases.dump'),
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..' 'unixmap.psd1'),
    [string]$OutputPath   = (Join-Path $PSScriptRoot '..' 'generated-aliases.ps1'),
    [switch]$ReportOnly
)

$ErrorActionPreference = 'Stop'

$manifest = Import-PowerShellDataFile -LiteralPath $ManifestPath
$dumpRaw  = Get-Content -LiteralPath $DumpPath

# Map the manifest's GitLogFormats keys onto the zsh variable names they came
# from, so the translator can substitute one for the other.
$logVarMap = @{
    '_git_log_fuller_format'         = 'GitLogFuller'
    '_git_log_oneline_format'        = 'GitLogOneline'
    '_git_log_oneline_medium_format' = 'GitLogOnelineMedium'
}

# POSIX-only tools. An alias whose body needs one of these cannot be ported by
# substitution — it needs a real shim — so it is skipped and reported.
$posixOnly = '(^|[\s|])(sed|awk|xargs|tr|cut|uniq|rev|tee|print)([\s|]|$)'

function ConvertTo-PSDefinition {
    param([string]$Name, [string]$Value)

    $v = $Value.Trim()
    if ($v.StartsWith("'") -and $v.EndsWith("'")) { $v = $v.Substring(1, $v.Length - 2) }

    # `cd "$(git-root || print .)"` — the only entry needing a real rewrite
    # rather than a substitution, so it is spelled out instead of generalised.
    if ($Name -ceq 'G..') {
        return @{ Ok = $true; Kind = 'function'; Body = 'Set-Location (git-root)'; NoArgs = $true }
    }

    if ($v -match $posixOnly) {
        return @{ Ok = $false; Reason = "uses a POSIX-only tool ($($Matches[2])); needs a shim, not a translation" }
    }

    # --pretty=format:"${_git_log_X_format}"  ->  "--pretty=format:$GitLogX"
    foreach ($zshVar in $logVarMap.Keys) {
        $psVar = $logVarMap[$zshVar]
        $v = $v -replace ('--pretty=format:"\$\{' + $zshVar + '\}"'), ('"--pretty=format:$' + $psVar + '"')
    }

    # "$(git-branch-current 2>/dev/null)" -> (git-branch-current)
    # The shim swallows its own errors, so the redirection is not needed.
    $v = $v -replace '"\$\(git-branch-current 2>/dev/null\)"', '(git-branch-current)'

    # $(GCl) -> @(GCl); an array argument splats to a native command
    $v = $v -replace '\$\(GCl\)', '@(GCl)'

    $v = $v -replace '2>/dev/null', '2>$null'

    # Anything still carrying shell syntax was not understood. Refuse.
    if ($v -match '\$\(|\$\{|`|\|\||>/dev/null') {
        return @{ Ok = $false; Reason = 'unhandled shell construct: ' + $v }
    }

    # A bare command name maps to a real alias, which does pass arguments
    # through. Only aliases with EMBEDDED arguments need to become functions.
    if ($v -notmatch '\s') {
        return @{ Ok = $true; Kind = 'alias'; Body = $v }
    }

    # @args on a compound command would attach to the last segment only, which
    # is not what the zsh alias means. Compound bodies take no arguments.
    $compound = $v -match '&&|\|\||\||;'
    return @{ Ok = $true; Kind = 'function'; Body = $v; NoArgs = $compound }
}

# --- parse and classify ---------------------------------------------------
# An ORDINAL dictionary, not @{}. A PowerShell hashtable case-folds its keys on
# insertion, so `$map['Gbx']` and `$map['GbX']` are one entry and the second
# write wins — and a later `-ccontains` against .Keys cannot undo that, because
# the distinct key is already gone. The first version of this used @{} with
# -ccontains and looked correct while silently emitting GbX and GSx, which are
# both on the exclude list. See the Matching section of unixmap.psd1.
$excludeMap = [System.Collections.Generic.Dictionary[string, string]]::new(
    [System.StringComparer]::Ordinal)
foreach ($e in $manifest.Exclude) { $excludeMap[$e.Name] = $e.Reason }

$emit    = [System.Collections.Generic.List[object]]::new()
$skipped = [System.Collections.Generic.List[object]]::new()

foreach ($line in $dumpRaw) {
    if ($line -match '^\s*#' -or $line -notmatch '^([^=]+)=(.*)$') { continue }
    $aliasName  = $Matches[1].Trim("'")
    $aliasValue = $Matches[2]

    if ($excludeMap.Keys -ccontains $aliasName) {
        $skipped.Add([pscustomobject]@{ Name = $aliasName; Reason = "excluded: $($excludeMap[$aliasName])" })
        continue
    }

    # tier A is the only tier this generator emits; everything else is either a
    # hand-written shim under functions/ or deliberately not ported.
    $tier = $null
    foreach ($r in $manifest.Rules) {
        if ($aliasName -cmatch $r.Match) { $tier = $r.Tier; break }
    }
    if ($tier -cne 'A') { continue }

    $def = ConvertTo-PSDefinition -Name $aliasName -Value $aliasValue
    if (-not $def.Ok) {
        $skipped.Add([pscustomobject]@{ Name = $aliasName; Reason = $def.Reason })
        continue
    }
    $emit.Add([pscustomobject]@{ Name = $aliasName; Kind = $def.Kind; Body = $def.Body; NoArgs = [bool]$def.NoArgs })
}

# --- collisions, computed from the running shell --------------------------
# A plain @{} is CORRECT here, and deliberately so: PowerShell command lookup
# is itself case-insensitive, so `Gl` really does collide with the built-in
# `gl`. This map should fold case; the exclude map above must not. Do not
# "fix" this one to match the other.
$existing = @{}
foreach ($a in Get-Alias) { $existing[$a.Name] = $a.Definition }

$displaced = foreach ($e in $emit) {
    if ($existing.ContainsKey($e.Name)) {
        [pscustomobject]@{ Name = $e.Name; Displaces = $existing[$e.Name] }
    }
}

# --- emit -----------------------------------------------------------------
$dumpHash = (Get-FileHash -LiteralPath $DumpPath -Algorithm SHA256).Hash.Substring(0, 12)
$sb = [System.Text.StringBuilder]::new()
$null = $sb.AppendLine(@"
# generated-aliases.ps1 — DO NOT EDIT.
#
# Regenerate with tools/Build-Aliases.ps1. Source of truth is the alias dump
# plus unixmap.psd1; edits here are lost on the next run.
#
# Source dump SHA256: $dumpHash
#
# No timestamp on purpose: identical inputs must produce an identical file, so
# that a diff means something changed upstream rather than that it was rebuilt.
"@)

$null = $sb.AppendLine()
$null = $sb.AppendLine('# git log formats, copied verbatim from the Zim git module.')
foreach ($k in ($manifest.GitLogFormats.Keys | Sort-Object)) {
    $val = $manifest.GitLogFormats[$k].Replace("'", "''")
    $null = $sb.AppendLine("`$script:GitLog$k = '$val'")
}

if ($displaced) {
    $null = $sb.AppendLine()
    $null = $sb.AppendLine('# Built-in aliases displaced by the definitions below. Resolution order is')
    $null = $sb.AppendLine('# Alias -> Function -> Cmdlet, so these must go or the functions are')
    $null = $sb.AppendLine('# unreachable. The cmdlets themselves are untouched — only the short forms.')
    foreach ($d in ($displaced | Sort-Object Name)) {
        $null = $sb.AppendLine("Remove-Alias -Name '$($d.Name)' -Force -ErrorAction SilentlyContinue  # was $($d.Displaces)")
    }
}

# --- case-collision groups ------------------------------------------------
# Zim's grammar uses CASE as its primary distinguisher, and capital means the
# more destructive variant: GwR is `git reset --hard` where Gwr is `--soft`.
# PowerShell command lookup is case-insensitive, so the two are ONE name and
# whichever is defined last wins.
#
# Emitting both would mean typing Gwr and getting a hard reset. So for each
# colliding group exactly one definition is emitted — the one with the FEWEST
# capitals, which by Zim's own convention is the least destructive — and it
# refuses to run if invoked under any other casing, naming what that variant
# would have done. Failing loudly beats doing the wrong git operation quietly.
$groups = $emit | Group-Object { $_.Name.ToLowerInvariant() }
$shadowed = [System.Collections.Generic.List[object]]::new()

$null = $sb.AppendLine()
$null = $sb.AppendLine('# --- ported aliases ---')

foreach ($g in ($groups | Sort-Object Name)) {
    $members = @($g.Group)
    $chosen  = $members |
        Sort-Object @{ Expression = { ($_.Name.ToCharArray() | Where-Object { [char]::IsUpper($_) }).Count } },
                    @{ Expression = { $_.Name } } |
        Select-Object -First 1

    $others = @($members | Where-Object { $_.Name -cne $chosen.Name })
    foreach ($o in $others) {
        $shadowed.Add([pscustomobject]@{ Name = $o.Name; ShadowedBy = $chosen.Name; Was = $o.Body })
    }

    if ($chosen.Kind -eq 'alias' -and $others.Count -eq 0) {
        $null = $sb.AppendLine("Set-Alias -Name '$($chosen.Name)' -Value '$($chosen.Body)' -Force")
        continue
    }

    $tail = if ($chosen.NoArgs) { '' } else { ' @args' }
    $body = if ($chosen.Kind -eq 'alias') { $chosen.Body } else { $chosen.Body }

    if ($others.Count -eq 0) {
        $null = $sb.AppendLine("function $($chosen.Name) { $body$tail }")
        continue
    }

    # Plain interpolation, not -f across a concatenation: -f binds tighter than
    # +, so it would format only the second fragment and leave {0} literal in
    # the first. These objects also carry .Body, not .Was — .Was exists only on
    # the report records below. Both mistakes shipped once and produced the
    # message "{0} ... Shadowed: GwR = " with the definition missing.
    $detail = ($others | ForEach-Object { "$($_.Name) = $($_.Body)" }) -join '; '
    $msg = "$($chosen.Name) is the only reachable casing here - PowerShell command names are case-insensitive. It runs: $body. Shadowed: $detail. Run the git command directly if you wanted one of those."
    $msg = $msg.Replace("'", "''")

    $null = $sb.AppendLine("function $($chosen.Name) {")
    $null = $sb.AppendLine("    if (`$MyInvocation.InvocationName -cne '$($chosen.Name)') {")
    $null = $sb.AppendLine("        Write-Error '$msg'; return")
    $null = $sb.AppendLine('    }')
    $null = $sb.AppendLine("    $body$tail")
    $null = $sb.AppendLine('}')
}

if (-not $ReportOnly) {
    [IO.File]::WriteAllText($OutputPath, $sb.ToString())
}

[pscustomobject]@{
    Translated      = $emit.Count
    Reachable       = @($groups).Count
    Shadowed        = $shadowed.Count
    ShadowedDetail  = @($shadowed | Sort-Object Name | ForEach-Object { "$($_.Name) -> $($_.ShadowedBy) kept; was: $($_.Was)" })
    Skipped         = $skipped.Count
    SkippedDetail   = @($skipped | ForEach-Object { "$($_.Name): $($_.Reason)" })
    Displaced       = @($displaced | ForEach-Object { "$($_.Name) (was $($_.Displaces))" })
    OutputPath      = if ($ReportOnly) { '(report only)' } else { $OutputPath }
    OutputLines     = ($sb.ToString() -split "`n").Count
}
