# Dotfiles — JetBrains AI Assistant Rules

## Safety
- Do not commit or push changes without an explicit user request.
- Do not read or suggest edits to files under `machines/*/local/` (credentials).
- Do not run destructive commands without user confirmation.

## Project Context
- Personal macOS dotfiles repo (Zsh + Zim)
- Config symlinks: `stow`-managed, targets in `config/`
- Machine-specific configs: `machines/Dales-MacBook-Pro.local/`
- Secrets live in `machines/*/local/` and are never tracked by git.

## Style
- Use `trash` not `rm` for file deletions in shell scripts.
- Prefer minimal, targeted edits.
