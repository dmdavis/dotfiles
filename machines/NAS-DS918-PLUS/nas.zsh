#!/usr/bin/env zsh
# NAS-DS918-PLUS shell profile. Auto-sourced at the end of .zshrc.

# fastfetch isn't packaged for DSM; give the shared `ff` a lightweight fallback.
if ! (( ${+commands[fastfetch]} )); then
  unfunction ff 2>/dev/null
  ff() {
    print -P "%F{cyan}${HOST}%f — $(uname -srm)"
    uptime
  }
fi

# Untracked host map / secrets (raw internal IPs, SSH ports, usernames).
for _f in "$DOTFILES/machines/$HOSTNAME"/local/*.zsh(N); do
  source "$_f"
done
unset _f
