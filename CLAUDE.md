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
| Read web pages | `defuddle parse <url> --md` | `WebFetch` | Strips nav/ads/boilerplate — far fewer tokens. Skip it for `.md` URLs, which are already clean. npm, not Homebrew: `npm i -g defuddle-cli`. |

Not installed: `sd`, `delta`, `eza` — ask before installing (see Safety).

## PowerShell (`powershell/`)

Windows shell configuration, tracked here so BEAST's shell is reproducible.
`pwsh` is installed locally (`brew "powershell"`), so everything below runs on
the Mac — no Windows machine needed to validate a change.

```
pwsh -File powershell/tools/Invoke-Lint.ps1      # lint; must be clean
pwsh -File powershell/tools/Build-Aliases.ps1    # regenerate the alias port
powershell/tools/dump-aliases.zsh                # refresh the input dump
```

Rules that are not obvious and have each already caused a bug:

- **`core.ps1` may never write to stdout.** `sshd` runs the default shell as
  `pwsh -c`, so any output corrupts every `ssh host '...'` result and breaks
  `scp` with *"Received message too long"*. Output belongs in
  `interactive.ps1`, which only loads in a real REPL.
- **PowerShell folds case almost everywhere** — comparisons, hashtable keys,
  command lookup, and *variable names*. Zim's git grammar is case-significant
  (`GSx` is submodule-remove, `Gsx` is stash drop), so consumers of
  `unixmap.psd1` must use `-ccontains` / `-cmatch` and an Ordinal dictionary.
  Read the `Matching` section of that file before touching the generator.
- **Aliases beat functions** in command resolution, so `function ls {}` is
  silently unreachable. `Remove-Alias` first.
- **`generated-aliases.ps1` is machine-written.** Edit `unixmap.psd1` or the
  generator, never the output. It is byte-identical across macOS and Windows by
  design; a diff means an input changed.
- **The three excluded lint rules are deliberate**, with reasoning in
  `PSScriptAnalyzerSettings.psd1`. Don't "fix" the code to satisfy them.

Full design record lives in the Obsidian vault: `Projects/PowerShell Parity on
Windows.md`.

## Out of Scope

Do not create new files unless clearly necessary. Do not add docs, comments, or
type annotations to code that wasn't changed.
