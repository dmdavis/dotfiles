# NUC10

Machine-specific zsh configuration for the Intel NUC-10 (Debian 13 / Proxmox VE).
Loaded automatically by `.zshrc` (`nuc.zsh`).

| File | Purpose |
|------|---------|
| `nuc.zsh` | Overrides the shared `ff` (the default logo path is Synology-only) to run plain `fastfetch`, and sources the untracked `local/` host map. |
| `local/` | Untracked (gitignored): host secrets / raw internal addresses, if any. |

## Notes

- zsh is the Debian **zsh** package (`/usr/bin/zsh`, 5.9); all Zim-required modules load.
  Login lands in zsh via **`chsh -s /usr/bin/zsh root`** — Debian keeps this across updates,
  unlike DSM on the NAS (which resets the account shell, forcing a `.profile` `exec`).
- No `env.zsh` is needed: the standard Debian login `PATH` already covers the toolchain.
- Expected tools are installed from apt: `zsh git fastfetch fd fzf ripgrep tmux lsd bat nnn stow`.
  Debian names two binaries differently — `fd-find`→`fdfind`, `bat`→`batcat` — so `~/bin/fd`
  and `~/bin/bat` shim them to the names the shared `.zshrc` expects (`~/bin` is first on `PATH`).
- The clone pulls over **HTTPS** (anonymous; `dmdavis/dotfiles` is public).
