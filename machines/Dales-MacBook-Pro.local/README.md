# Machine Profile: Dales-MacBook-Pro.local

This directory contains configuration specific to this machine that is tracked in version control.

## Files in this profile

- `nas.zsh` - NAS/NUC/Pi-hole connection helpers (checked into git with placeholder values)

## Local overrides (untracked)

Create a `local/` subdirectory here for machine-specific configs that should NOT be tracked:
```bash
mkdir -p local
```

Then create hook files as needed:
- `local/env.zsh` - Environment variables (sourced in `.zshenv`)
- `local/zshrc-pre.zsh` - Pre-Zim configuration
- `local/zshrc-post-zim.zsh` - Post-Zim configuration
- `local/zshrc-final.zsh` - Final aliases/functions

Example: Put your actual NAS credentials in `local/nas-secrets.zsh` and source it from `nas.zsh`.
