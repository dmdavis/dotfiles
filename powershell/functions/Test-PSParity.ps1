function Test-PSParity {
    <#
    .SYNOPSIS
        Report every signal the profile uses to decide whether a session is
        interactive, plus what actually loaded.

    .DESCRIPTION
        Exists because the interactivity decision cannot be observed remotely:
        `ssh -tt` to a Windows box running pwsh as DefaultShell swallows output
        through ConPTY and may not run the command at all. So the logic was
        verified against synthetic argument sets, and this reports the real
        thing from inside a session you are actually sitting in.

        Defined in core.ps1's function sweep, so it is available in
        non-interactive sessions too — which is the point, since the failure
        mode being checked for is "interactive config never loads".

    .EXAMPLE
        Test-PSParity

        Run it in an interactive session. Interactive should be True and
        InputRedirected should be False. If Interactive is False in a session
        you typed this into by hand, the detection is failing closed and
        InputRedirected is almost certainly why.
    #>
    [CmdletBinding()]
    param()

    # A try/catch IS legal as a hashtable value — but only if no key follows
    # it. `@{ A = try {} catch {} ; B = 1 }` is a parse error raised at B, and
    # the error is reported against the opening `@{` line rather than the
    # culprit, which is why it reads as an unbalanced brace. Parenthesising the
    # try/catch also fixes it; hoisting into variables is clearer. Measured on
    # pwsh 7.6.3, not assumed.
    $inRedir  = try { [Console]::IsInputRedirected }  catch { 'threw' }
    $outRedir = try { [Console]::IsOutputRedirected } catch { 'threw' }

    [pscustomobject][ordered]@{
        Interactive      = $global:PSParityInteractive
        ConfigRoot       = $PSParityRoot
        InputRedirected  = $inRedir
        OutputRedirected = $outRedir
        UserInteractive  = [Environment]::UserInteractive
        HostName         = $Host.Name
        PSReadLineLoaded = [bool](Get-Module PSReadLine)
        LoadErrors       = $global:PSParityLoadErrors
        CommandLineArgs  = ([Environment]::GetCommandLineArgs() -join ' ')
    }
}
