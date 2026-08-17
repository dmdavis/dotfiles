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

# --- manifest consistency -------------------------------------------------
# unixmap.psd1 once declared six shim files that had never been written, and
# generated-aliases.ps1 shipped calling two functions that did not exist, so
# G.. / Gpc / Gpp failed at the prompt. A manifest that describes an intention
# rather than the tree is worse than no manifest. Cheap to check, so check it.
$manifestPath = Join-Path $Path 'unixmap.psd1'
$manifestProblems = @()
if (Test-Path -LiteralPath $manifestPath) {
    $manifest  = Import-PowerShellDataFile -LiteralPath $manifestPath
    $fnDir     = Join-Path $Path 'functions'
    $onDisk    = if (Test-Path $fnDir) { (Get-ChildItem $fnDir -Filter '*.ps1' -File).Name } else { @() }
    foreach ($declared in ($manifest.Shims.File | Sort-Object -Unique)) {
        if ($declared -notin $onDisk) {
            $manifestProblems += "unixmap.psd1 declares functions/$declared, which does not exist"
        }
    }
}
if ($manifestProblems) {
    $manifestProblems | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    if ($Strict) { exit 1 }
}

$files = Get-ChildItem -Path $Path -Recurse -Include '*.ps1', '*.psd1' -File |
    Where-Object { $_.Name -ne 'generated-aliases.ps1' }

# --- parse check ----------------------------------------------------------
# PSScriptAnalyzer reports a file it cannot PARSE as clean rather than as
# broken, so a syntax error sails through the lint gate and only fails when the
# profile tries to load it. Found the hard way: an unterminated Unicode escape
# in Get-UnixMap.ps1 passed "clean across 18 files" and then failed at load.
# Parse first, and treat a parse error as fatal regardless of -Strict.
$parseFailures = @()
foreach ($f in $files) {
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $f.FullName, [ref]$null, [ref]$parseErrors)
    foreach ($pe in $parseErrors) {
        $parseFailures += "{0}:{1}  PARSE  {2}" -f $f.Name, $pe.Extent.StartLineNumber, $pe.Message
    }
}
if ($parseFailures) {
    $parseFailures | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    Write-Host "$($parseFailures.Count) parse error(s) — these break the profile at load." -ForegroundColor Red
    exit 1
}

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
