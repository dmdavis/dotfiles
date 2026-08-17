#Requires -Version 7.0
<#
.SYNOPSIS
    Lint powershell/ with PSScriptAnalyzer.

.DESCRIPTION
    Runs against ../PSScriptAnalyzerSettings.psd1, which excludes three default
    rules that are wrong for a shell profile — each with its reasoning written
    out in that file.

    generated-aliases.ps1 is skipped: it is machine-written, and any finding in
    it is a bug in tools/Build-Aliases.ps1 rather than something to edit.

    Requires PSScriptAnalyzer:
        Install-Module PSScriptAnalyzer -Scope CurrentUser

.EXAMPLE
    pwsh -File tools/Invoke-Lint.ps1
#>
[CmdletBinding()]
param(
    [string]$Path         = (Join-Path $PSScriptRoot '..'),
    [string]$SettingsPath = (Join-Path $PSScriptRoot '..' 'PSScriptAnalyzerSettings.psd1'),
    # Fail the run on findings, for use in a pre-commit hook or CI.
    [switch]$Strict
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Error 'PSScriptAnalyzer is not installed. Install-Module PSScriptAnalyzer -Scope CurrentUser'
    exit 2
}
Import-Module PSScriptAnalyzer

$files = Get-ChildItem -Path $Path -Recurse -Include '*.ps1', '*.psd1' -File |
    Where-Object { $_.Name -ne 'generated-aliases.ps1' }

$findings = foreach ($f in $files) {
    Invoke-ScriptAnalyzer -Path $f.FullName -Settings $SettingsPath
}

if (-not $findings) {
    Write-Host "PSScriptAnalyzer: clean across $($files.Count) files." -ForegroundColor Green
    exit 0
}

$findings |
    Sort-Object Severity, ScriptName, Line |
    Format-Table @{ N = 'File'; E = { Split-Path $_.ScriptName -Leaf } },
                 Line, Severity, RuleName, Message -AutoSize -Wrap

Write-Host "$($findings.Count) finding(s) across $($files.Count) files." -ForegroundColor Yellow
if ($Strict) { exit 1 }
