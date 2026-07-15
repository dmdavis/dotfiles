#!/usr/bin/env zsh
# NUC10 (Debian 13 / Proxmox VE) shell profile. Auto-sourced at the end of .zshrc.

# The shared `ff` points at a Synology-only logo path; on the NUC just run
# fastfetch with its built-in OS logo.
unfunction ff 2>/dev/null
ff() { fastfetch }

# Untracked host map / secrets (gitignored: machines/*/local/).
for _f in "$DOTFILES/machines/$HOSTNAME"/local/*.zsh(N); do
  source "$_f"
done
unset _f
