# NAS-DS918-PLUS

Machine-specific zsh configuration for the Synology DS918+ NAS (DSM 7.3.2).
Loaded automatically by `.zshenv` (`env.zsh`) and `.zshrc` (other `*.zsh` files).

| File | Purpose |
|------|---------|
| `env.zsh` | Prepends `/usr/local/bin` (SynoCommunity/SynoCli) and `/opt/bin` (Entware) to `PATH`. |
| `nas.zsh` | `ff` fallback (fastfetch isn't packaged for DSM) and sources the untracked `local/` host map. |
| `local/` | Untracked (gitignored): raw internal IPs, SSH ports, usernames. |

## Notes

- zsh is the SynoCommunity **zsh-static** package (`/usr/local/bin/zsh`, 5.9.2);
  all Zim-required modules load. Login lands in zsh via `~/.profile` `exec`, not
  `chsh` (DSM resets the account shell on updates).
- Present under `/usr/local/bin`: `fd fzf lsd nnn rg tmux bat eza node npm mosh
  rsync sd procs xstow` and more. Absent from the box: `fastfetch yazi zoxide vivid
  mise fnm stow` — the shared `.zshrc` guards these, so they degrade cleanly.
