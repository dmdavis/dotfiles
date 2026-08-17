# Get-UnixMap.ps1 — the discovery command. Alias: unixhelp
#
# Reads unixmap.psd1 and reports what was ported, what was not, and WHY. It is
# generated from the same manifest the shims and the generator use, so it
# cannot drift from them — that was the founding design decision of this whole
# project, and this is the consumer that makes it pay.
#
# It goes one step further than the manifest: every entry is checked against
# the live session with Get-Command, so the Status column reports what is
# actually reachable right now rather than what the manifest intends. That is
# the check that would have caught six shim files being declared and never
# written.

function Get-UnixMap {
    <#
    .SYNOPSIS
        What ported from zsh to PowerShell, what didn't, and why.

    .DESCRIPTION
        Bare call prints everything grouped by category. Narrow it with a name,
        a -Group, or one of the switches.

        Status is resolved live, not read from the manifest:
          OK       the command exists in this session
          MISSING  the manifest says it should exist and it does not
          n/a      requires a tool that is not installed here

    .PARAMETER Name
        A command name. Works for ported shims, generated git aliases, and
        shadowed names — asking about GwR explains where it went.

    .PARAMETER Missing
        What was deliberately not ported, with the reason for each.

    .PARAMETER Shadowed
        The zsh names unreachable here because PowerShell folds case.

    .PARAMETER Traps
        Built-ins that mean something different from the Unix command of the
        same name. Read this one early.

    .PARAMETER Idioms
        How PowerShell differs from zsh in ways that matter at the prompt.

    .EXAMPLE
        unixhelp
    .EXAMPLE
        unixhelp grep
    .EXAMPLE
        unixhelp GwR          # why is this gone?
    .EXAMPLE
        unixhelp -Traps
    .EXAMPLE
        unixhelp -Idioms formatting
    #>
    # The switches below exist to SELECT a parameter set; the dispatch reads
    # $PSCmdlet.ParameterSetName, so the switch variables are never referenced
    # by name. That is the idiomatic pattern for mutually exclusive modes and
    # the rule cannot see it.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '',
        Justification = 'Switches select a parameter set; dispatch is on $PSCmdlet.ParameterSetName.')]
    [CmdletBinding(DefaultParameterSetName = 'Find')]
    param(
        [Parameter(Position = 0, ParameterSetName = 'Find')]
        [string]$Name,

        [Parameter(ParameterSetName = 'Find')]
        [string]$Group,

        [Parameter(ParameterSetName = 'Missing')]
        [switch]$Missing,

        [Parameter(ParameterSetName = 'Shadowed')]
        [switch]$Shadowed,

        [Parameter(ParameterSetName = 'Traps')]
        [switch]$Traps,

        [Parameter(ParameterSetName = 'Idioms')]
        [switch]$Idioms,

        [Parameter(Position = 0, ParameterSetName = 'Idioms')]
        [string]$Topic,

        [Parameter(ParameterSetName = 'Packages')]
        [switch]$Packages
    )

    $manifestPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'unixmap.psd1'
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        Write-Error "unixmap.psd1 not found at $manifestPath"
        return
    }
    # Cached because this is an interactive command that may be run repeatedly,
    # and re-parsing a psd1 on every keystroke of exploration is wasteful.
    if (-not $script:UnixMapCache -or $script:UnixMapCachePath -ne $manifestPath) {
        $script:UnixMapCache     = Import-PowerShellDataFile -LiteralPath $manifestPath
        $script:UnixMapCachePath = $manifestPath
    }
    $map = $script:UnixMapCache

    function Resolve-Status([string]$CommandName, [string]$RequiredTool) {
        if (Get-Command $CommandName -ErrorAction SilentlyContinue) { return 'OK' }
        if ($RequiredTool -and -not (Get-Command $RequiredTool -ErrorAction SilentlyContinue)) {
            return "n/a ($RequiredTool)"
        }
        'MISSING'
    }

    switch ($PSCmdlet.ParameterSetName) {

        'Missing' {
            return $map.NotPorted | ForEach-Object {
                [pscustomobject]@{
                    Name    = $_.Name
                    Reason  = $_.Reason
                    Instead = $_.Instead
                }
            }
        }

        'Shadowed' {
            if (-not $script:PSParityShadowed) {
                Write-Warning 'No shadow data. generated-aliases.ps1 has not been loaded or predates the shadow map.'
                return
            }
            return $script:PSParityShadowed | Sort-Object Name | ForEach-Object {
                [pscustomobject]@{
                    Unreachable = $_.Name
                    Was         = $_.Was
                    UseInstead  = "$($_.KeptAs), or the git command directly"
                }
            }
        }

        'Traps' {
            return $map.Traps | ForEach-Object {
                [pscustomobject]@{ Name = $_.Name; Really = $_.Is; Note = $_.Note }
            }
        }

        'Packages' {
            return $map.Packages | ForEach-Object {
                [pscustomobject]@{ Name = $_.Name; Runs = $_.Runs; Note = $_.Note }
            }
        }

        'Idioms' {
            $items = $map.Idioms
            if ($Topic) { $items = $items | Where-Object { $_.Topic -like "*$Topic*" } }
            if (-not $items) {
                Write-Warning "No idiom matching '$Topic'. Try: $(($map.Idioms.Topic) -join ', ')"
                return
            }
            return $items | ForEach-Object {
                [pscustomobject]@{ Topic = $_.Topic; Summary = $_.Summary; Detail = $_.Detail }
            }
        }

        default {
            # A specific name: check the shims, then the shadow list, then fall
            # back to whatever the session actually has — which covers the 111
            # generated git aliases without duplicating them in the manifest.
            if ($Name) {
                $shim = $map.Shims | Where-Object { $_.Name -eq $Name }
                if ($shim) {
                    return $shim | ForEach-Object {
                        [pscustomobject]@{
                            Name     = $_.Name
                            Kind     = 'shim'
                            Status   = Resolve-Status $_.Name $_.Requires
                            Group    = $_.Group
                            File     = "functions/$($_.File)"
                            Requires = $_.Requires
                            Note     = $_.Note
                        }
                    }
                }

                $shadow = $script:PSParityShadowed | Where-Object { $_.Name -ceq $Name }
                if ($shadow) {
                    return [pscustomobject]@{
                        Name   = $Name
                        Kind   = 'shadowed'
                        Status = 'unreachable'
                        Note   = "PowerShell folds case, so this collides with $($shadow.KeptAs). It was: $($shadow.Was). Run that git command directly."
                    }
                }

                $gone = $map.NotPorted | Where-Object { $_.Names -contains $Name }
                if ($gone) {
                    return [pscustomobject]@{
                        Name   = $Name
                        Kind   = 'not ported'
                        Status = 'n/a'
                        Note   = "$($gone.Reason)$(if ($gone.Instead) { ' Instead: ' + $gone.Instead })"
                    }
                }

                $live = Get-Command $Name -ErrorAction SilentlyContinue
                if ($live) {
                    return [pscustomobject]@{
                        Name   = $live.Name
                        Kind   = if ($live.Name -cmatch '^G') { 'generated (tier A)' } else { $live.CommandType.ToString().ToLower() }
                        Status = 'OK'
                        Note   = ($live.Definition -replace '\s+', ' ').Trim()
                    }
                }

                # No backticks in this string: a backtick is PowerShell's escape
                # character, and "`u" specifically begins a Unicode escape, so
                # markdown-style quoting of a command name is a parse error.
                Write-Warning "Nothing known about '$Name'. Try: unixhelp (bare), unixhelp -Missing, or unixhelp -Shadowed."
                return
            }

            # Bare call, or filtered by group.
            $shims = $map.Shims
            if ($Group) { $shims = $shims | Where-Object { $_.Group -like "*$Group*" } }

            $rows = $shims | ForEach-Object {
                [pscustomobject]@{
                    Name     = $_.Name
                    Group    = $_.Group
                    Status   = Resolve-Status $_.Name $_.Requires
                    Requires = $_.Requires
                    Note     = $_.Note
                }
            }

            if (-not $Group) {
                $generated = @(Get-ChildItem Function: | Where-Object { $_.Name -cmatch '^G' }).Count
                Write-Host ''
                Write-Host '  zsh -> PowerShell' -ForegroundColor Cyan
                Write-Host "  $generated generated git aliases - $(@($map.Shims).Count) shims - $(@($map.NotPorted).Count) not ported - $(@($script:PSParityShadowed).Count) shadowed by case" -ForegroundColor DarkGray
                Write-Host '  unixhelp <name> | -Missing | -Shadowed | -Traps | -Idioms | -Packages' -ForegroundColor DarkGray
                Write-Host ''
            }
            return $rows | Sort-Object Group, Name
        }
    }
}

Set-Alias -Name unixhelp -Value Get-UnixMap -Force
