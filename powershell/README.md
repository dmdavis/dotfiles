# PowerShell configuration

Tracked PowerShell 7 configuration for Windows machines, so the shell there is
reproducible instead of living loose on the box.

## How it loads

`$PROFILE.CurrentUserAllHosts` holds a two-line stub that dot-sources
`profile.ps1` from this directory. `profile.ps1` decides whether the session is
interactive, then loads:

| File | When | May print? |
|---|---|---|
| `core.ps1` | always | **no — never** |
| `generated-aliases.ps1` | always, via `core.ps1` | no |
| `functions/*.ps1` | always, via `core.ps1` | no |
| `interactive.ps1` | interactive REPL only | yes |

The split is not cosmetic. `sshd` runs the default shell as `pwsh -c`, so
anything written to stdout during a non-interactive load corrupts every
`ssh host '...'` result and breaks `scp` with *"Received message too long"*.

## One manifest, and everything else is generated

`unixmap.psd1` is the source of truth: name, PowerShell equivalent, tier,
reason. Nothing downstream is hand-maintained, because three hand-kept copies
of the same mapping disagree within a month.

| Run | Produces | When |
|---|---|---|
| `tools/dump-aliases.zsh` | `zsh-aliases.dump` | on the Mac, when the zsh side changes |
| `tools/Build-Aliases.ps1` | `generated-aliases.ps1` | after a new dump, or a manifest rule change |
| `tools/Build-Winget.ps1` | `winget.json` | after a `Tools` change |
| `tools/Build-VaultTable.ps1` | Markdown on stdout, for the notes | after any manifest change |
| `tools/Invoke-Lint.ps1 -Strict` | pass/fail | before every commit |

`Get-UnixMap` (`unixhelp`) is the fifth consumer and generates nothing — it
reads the manifest live and resolves each entry's status with `Get-Command`, so
it reports what the session can actually reach rather than what the manifest
intends.

## Gotchas

- **Aliases beat functions.** PowerShell resolves Alias → Function → Cmdlet →
  Application, so `function ls { ... }` is silently shadowed by the built-in
  `ls` alias. Call `Remove-Alias <name> -Force` first.
- **`diff` is `Compare-Object`**, and takes entirely different arguments.
- Dot-source with a `foreach` statement, never `ForEach-Object` — see
  `core.ps1`.
