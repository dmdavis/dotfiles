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

## Preferred Tools

Fast tools are installed (Homebrew, on PATH) — prefer them over the POSIX defaults.

| Task | Use | Instead of | Notes |
|------|-----|-----------|-------|
| Search text | `rg` | `grep -r` | Much faster. Skips `.git` by default; use `--hidden` to reach dotfiles at the repo root. |
| Find files | `fd` | `find` | `fd pattern` / `fd -e zsh`. Skips hidden files — most of this repo is hidden, so `fd -H` is usually what you want. |
| Delete files | `trash` | `rm` | Recoverable from Finder. |
| YAML | `yq` | hand-parsing | |
| JSON | `jq` | — | Also for `.claude/` and `.idea/` configs. |
| XML / HTML | `xq` | — | |
| macOS plists | `plutil` | — | `plutil -extract <key> raw -o - <file>`; see `darwin.zsh` for the Postgres.app usage. |
| Preview markdown | `glow` | `cat` | Rendered terminal output. |
| Nicer listing / view | `lsd`, `bat` | `ls`, `cat` | |
| GitHub | `gh` | web/API by hand | |

Not installed: `sd`, `delta`, `eza` — ask before installing (see Safety).

## Out of Scope

Do not create new files unless clearly necessary. Do not add docs, comments, or
type annotations to code that wasn't changed.
