#
# PSScriptAnalyzer settings for powershell/.
#
# Three default rules are excluded. Each is a real rule that is wrong for a
# SHELL PROFILE specifically, and each is written up so the next pass — human
# or LLM — does not "fix" the code to satisfy a linter that does not know the
# context. If a rule is ever excluded here without a reason, that is a bug.
#
# Run:  pwsh -File tools/Invoke-Lint.ps1
#
@{
    Severity = @('Error', 'Warning')

    ExcludeRules = @(
        # PSAvoidGlobalVars
        #   A shell profile's job is to put things in the global scope. The
        #   whole design depends on $global:PSParityInteractive being visible
        #   to interactive.ps1 and to Test-PSParity, and on
        #   $global:PSParityLoadErrors surviving from core.ps1 to whoever
        #   reports it. Script scope would defeat the purpose entirely.
        'PSAvoidGlobalVars',

        # PSAvoidUsingWriteHost
        #   Inverted here. Write-Host is the ONLY correct choice for the
        #   interactive banner, because its output must reach the terminal and
        #   must NOT enter the pipeline. Write-Output would put the banner on
        #   stdout, which is exactly the bug that broke scp to BEAST and
        #   corrupted every structured `ssh host '...'` result. The rule
        #   assumes library code; this is a profile.
        'PSAvoidUsingWriteHost',

        # PSUseBOMForUnicodeEncodedFile
        #   These files are UTF-8 without a BOM on purpose: git treats them as
        #   text cleanly, and generated output must be byte-identical across
        #   macOS and Windows. The rule exists for Windows PowerShell 5.1,
        #   which misreads BOM-less UTF-8 as ANSI — but everything here is
        #   #Requires -Version 7.0 or loaded only by pwsh 7, which reads
        #   BOM-less UTF-8 correctly. The non-ASCII is in comments regardless.
        'PSUseBOMForUnicodeEncodedFile'
    )
}
