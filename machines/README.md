# Machine Profiles

This directory contains machine-specific configurations that ARE tracked in version control.

## When to use machine profiles vs local/

**Use `machines/<hostname>/`** for:
- Configuration you want to share across fresh OS installs
- Settings you want to track in git (can reference in documentation)
- Patterns/templates you might reuse on other machines
- Example: network helpers, common aliases for a specific machine type

**Use `local/` or `machines/<hostname>/local/`** for:
- Secrets, API keys, credentials
- Local paths unique to one installation
- Temporary experiments
- Anything that should never be committed

## Creating a new machine profile

1. Find your hostname:
   ```bash
   hostname
   ```

2. Create profile directory:
   ```bash
   mkdir -p "machines/$(hostname)"
   ```

3. Add `.zsh` files:
   - Any `.zsh` file in the profile will be auto-sourced in `.zshrc`
   - Files are loaded in alphabetical order
   - Consider prefixing with numbers if order matters: `01-env.zsh`, `02-aliases.zsh`

4. For untracked configs, create a `local/` subdirectory:
   ```bash
   mkdir -p "machines/$(hostname)/local"
   ```

## Hook points

Machine profiles can use the same hook points as the global `local/` directory:

- `env.zsh` - Sourced in `.zshenv`
- `zshrc-pre.zsh` - Before Zim initialization
- `zshrc-post-zim.zsh` - After Zim loads
- `zshrc-final.zsh` - At the end of `.zshrc`
- `local/` subdirectory - Same hooks, but untracked

## Example structure

```
machines/
├── work-laptop/
│   ├── env.zsh           # Work-specific PATH entries (tracked)
│   ├── aliases.zsh       # Work aliases (tracked)
│   └── local/
│       └── secrets.zsh   # Company VPN, keys (untracked)
├── home-server/
│   └── systemd.zsh       # Server management helpers (tracked)
└── Dales-MacBook-Pro.local/
    ├── nas.zsh           # NAS helpers template (tracked)
    └── local/
        └── nas-creds.zsh # Actual IPs and credentials (untracked)
```
