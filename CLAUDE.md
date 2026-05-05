# Dale's Dotfiles

Personal macOS dotfiles. Machine-specific configs live in `machines/<hostname>/`;
secrets live in `machines/<hostname>/local/` (not tracked).

## Safety

- **Never commit** without an explicit user request.
- **Never push** to the remote without explicit confirmation.
- **Never read or modify** files under `machines/*/local/` — they contain credentials.
- **Never run destructive shell commands** (rm -rf, git reset --hard, etc.) without asking.
- Prefer targeted edits over large rewrites.

## Conventions

- Shell: Zsh with Zim framework (`.zimrc`, `.zshrc`)
- Config symlinks managed via `stow` (see `install` script); targets go in `config/`
- Brewfile lives at `machines/Dales-MacBook-Pro.local/Brewfile`
- Machine env vars: `machines/Dales-MacBook-Pro.local/env.zsh`
- NAS helpers: `machines/Dales-MacBook-Pro.local/nas.zsh`
- Use `trash` (not `rm`) to delete files

## Out of Scope

Do not create new files unless clearly necessary. Do not add docs, comments, or
type annotations to code that wasn't changed.
