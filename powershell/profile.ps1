# ~/.files/powershell/profile.ps1 — entry point for the tracked PowerShell config.
#
# Loaded by a two-line stub at $PROFILE.CurrentUserAllHosts. The stub is the only
# machine-local piece; everything real lives here, in the repo.
#
# Why a stub instead of putting content in $PROFILE: that path resolves under
# Documents, which Windows 11 frequently redirects into OneDrive. Shell config
# does not belong in OneDrive. Symlinks would also work but need Developer Mode
# or elevation, so a stub is the less fragile option.
#
# Vault: Projects/PowerShell Parity on Windows.md

$PSParityRoot = $PSScriptRoot

# Is this a real interactive REPL, or `pwsh -c` / -EncodedCommand / -File / stdin?
#
# THIS IS LOAD-BEARING. sshd runs DefaultShell with -c, so anything printed
# during a non-interactive load lands at the front of every `ssh host '...'`
# result — corrupting JSON — and breaks scp outright with
# "scp: Received message too long".
#
# Two independent signals, OR'd, because either one alone has a hole:
#
#   1. Redirected stdin. Catches `pwsh -` and anything piped, which no flag
#      check sees. A real console — local, or SSH with a pty — is not
#      redirected. If the check throws, assume redirected; that is the safe
#      direction.
#   2. A non-interactive switch. Catches `pwsh -Command` in a pty, where stdin
#      can still look like a console. The alternation is spelled out rather
#      than using a loose `^-e` prefix, which would also swallow
#      -ExecutionPolicy and suppress the prompt on a normal REPL.
#
# Both failure modes are one-way by design: a misread costs the prompt and the
# banner, but never leaks output into a machine-readable stream.
#
# DO NOT reach for [Environment]::UserInteractive as a third signal. Measured
# in a hand-typed `ssh beast` session on 2026-08-16 — a real prompt, PSReadLine
# loaded — it reports False. Gating on it means the interactive configuration
# never loads over SSH at all. IsInputRedirected got the same session right.
$isRedirected = try { [Console]::IsInputRedirected } catch { $true }

$nonInteractiveSwitch =
    '^-(c|co|com|comm|comma|comman|command' +
    '|e|ec|enc|enco|encod|encode|encoded|encodedcommand' +
    '|f|fi|fil|file' +
    '|noni|noninteractive)$'

$global:PSParityInteractive = -not (
    $isRedirected -or
    [bool]([Environment]::GetCommandLineArgs() |
        Where-Object { $_ -eq '-' -or $_ -match $nonInteractiveSwitch })
)

. (Join-Path $PSParityRoot 'core.ps1')

if ($global:PSParityInteractive) {
    . (Join-Path $PSParityRoot 'interactive.ps1')
}
