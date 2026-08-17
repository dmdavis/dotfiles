# interactive.ps1 — loaded only in a real REPL. Free to write to stdout.

# --- PSReadLine (Phase C4) -----------------------------------------------
# Target: -EditMode Emacs for zsh keybindings, ListView prediction, and
# Up/Down bound to HistorySearchBackward/Forward to reproduce
# zsh-history-substring-search. Not written yet.

# --- prompt (Phase C4) ---------------------------------------------------
# Open question: starship (cross-shell, matches the Mac) vs oh-my-posh.

# --- completion / fzf (Phase C4) -----------------------------------------

# --- banner --------------------------------------------------------------
# Replaces the old machine-local "Microsoft.Powershell_profile.ps1 done".
# Useful while the config is in flux because it names the source on disk — if
# this line is missing, the stub did not find the repo. Delete once the
# Phase C4 prompt makes the load obvious.
Write-Host 'powershell config: ' -NoNewline -ForegroundColor DarkGray
Write-Host $PSParityRoot -ForegroundColor DarkCyan
