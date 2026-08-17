# interactive.ps1 — loaded only in a real REPL. Free to write to stdout.
#
# Everything here is guarded on the tool or module actually being present, so a
# machine that has not run bootstrap.ps1 gets a working shell rather than a
# screenful of errors. core.ps1 has already loaded aliases and shims by now.

# zoxide and starship are both initialised by evaluating the shell code they
# print. Invoke-Expression is the documented and only supported way to do that
# for either tool, and the input is the tool's own output rather than anything
# user-supplied. Suppressed at file scope rather than in the settings file —
# the rule is worth keeping everywhere else.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '',
    Justification = 'Required by zoxide init and starship init; input is each tool own output.')]
param()

# --- PSReadLine -----------------------------------------------------------
# The biggest single win, and the one that changes the shell most. Each option
# below maps to something already configured in .zshrc.
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -EditMode Emacs            # .zshrc: bindkey -e
    Set-PSReadLineOption -HistoryNoDuplicates       # .zshrc: HIST_IGNORE_ALL_DUPS
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -ShowToolTips

    # .zshrc removes / from WORDCHARS so Alt-B/Alt-F stop at path segments.
    Set-PSReadLineOption -WordDelimiters ' /\:;,.()[]{}<>|&'

    # zsh-autosuggestions. ListView needs PSReadLine 2.2+; BEAST has 2.4.5.
    # HistoryAndPlugin picks up CompletionPredictor when it is installed.
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView
    } catch {
        # Older PSReadLine: fall back rather than leave the shell unconfigured.
        try {
            Set-PSReadLineOption -PredictionSource History
        } catch {
            # Not swallowed: an unusable PSReadLine is worth surfacing, and
            # core.ps1's collector is the channel that never touches stdout.
            $global:PSParityLoadErrors += [pscustomobject]@{
                File  = 'interactive.ps1'
                Stage = 'run'
                Error = "PSReadLine prediction unavailable: $($_.Exception.Message)"
            }
        }
    }

    # zsh-history-substring-search: Up/Down filter on what is already typed,
    # rather than walking raw history. This is the binding most worth having.
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key 'Ctrl+p'  -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key 'Ctrl+n'  -Function HistorySearchForward

    # Accept the inline suggestion a word at a time, as in fish and zsh.
    Set-PSReadLineKeyHandler -Key 'Alt+f'   -Function ForwardWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+f'  -Function AcceptSuggestion
}

# --- fzf ------------------------------------------------------------------
# Ctrl+R and Ctrl+T, matching the Zim fzf module. Loaded AFTER PSReadLine so
# its chords win over the bindings set above.
if ((Get-Module -ListAvailable -Name PSFzf) -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# --- zoxide ---------------------------------------------------------------
# Provides `z`. The zsh side calls this through autojump's `j`, but zoxide's
# own init defines `z` and `zi`, and inventing a `j` wrapper here would drift
# from whatever zoxide does next.
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --hook prompt | Out-String) })
}

# --- Terminal-Icons -------------------------------------------------------
# Only decorates Get-ChildItem, which the lsd shims mostly replace, and it
# renders as boxes without a Nerd Font. Opt in with $env:PSPARITY_ICONS=1
# rather than defaulting to something that may look broken.
if ($env:PSPARITY_ICONS -eq '1' -and (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Import-Module Terminal-Icons
}

# --- prompt ---------------------------------------------------------------
# starship, chosen over oh-my-posh: cross-shell, and the Mac already runs
# asciiship (Zim's starship-alike). No starship.toml is shipped yet, so this
# is stock starship — see the open question in the vault note.
#
# Must come last: starship overrides the prompt function, and zoxide's
# --hook prompt wraps whatever prompt exists when it initialises.
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $env:STARSHIP_SHELL = 'powershell'
    Invoke-Expression (& starship init powershell)
}

# --- load failures -------------------------------------------------------
# core.ps1 collects these instead of printing them, because it is forbidden
# from writing to stdout. This is the first place it is safe to say so.
if ($global:PSParityLoadErrors.Count) {
    Write-Host ("powershell config: {0} file(s) failed to load — run Test-PSParity" -f `
        $global:PSParityLoadErrors.Count) -ForegroundColor Red
}

# --- banner --------------------------------------------------------------
# Replaces the old machine-local "Microsoft.Powershell_profile.ps1 done".
# Useful while the config is in flux because it names the source on disk — if
# this line is missing, the stub did not find the repo. Delete once the
# prompt makes the load obvious.
Write-Host 'powershell config: ' -NoNewline -ForegroundColor DarkGray
Write-Host $PSParityRoot -ForegroundColor DarkCyan
