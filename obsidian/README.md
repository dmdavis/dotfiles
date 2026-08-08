# Obsidian Templates

Templates shared between independent Obsidian vaults (home vs. the GEICO
work vault — they're separate iCloud/Sync accounts, so nothing else keeps
them in sync). Nothing here is vault-specific data, only Templater syntax,
so it's safe to track publicly.

## Setup on a new machine

1. Clone (or pull) this repo:

   ```sh
   git clone git@github.com:dmdavis/dotfiles.git ~/.files
   ```

2. Set `OBSIDIAN_VAULT_DIR` for this machine in `machines/$HOSTNAME/env.zsh`
   (tracked) or `machines/$HOSTNAME/local/env.zsh` (untracked, if the path
   itself shouldn't be public — e.g. a work machine):

   ```sh
   export OBSIDIAN_VAULT_DIR="$HOME/path/to/vault"
   ```

3. Install the plugins the template depends on: `templater-obsidian`,
   `dataview`, and `customjs` (supplies `cJS()`/`Widgets` for the
   daily-quote block — without it that block throws instead of rendering).

4. Pull the template into the vault:

   ```sh
   obsidian-template-pull
   ```

## Functions

Defined in `darwin.zsh`, loaded on any macOS machine.

- `obsidian-template-push` — copy `$OBSIDIAN_VAULT_DIR/Resources/Obsidian/Templates/Daily Note Template.md`
  into this repo. Run after editing the template in the source vault (home).
  Doesn't commit — review the diff and commit by hand.
- `obsidian-template-pull` — `git pull --ff-only`, then copy this repo's
  template into `$OBSIDIAN_VAULT_DIR`. Run on the destination vault (work)
  to pick up the latest version.

## Why copy instead of symlink

The work vault syncs over a separate iCloud/Obsidian Sync account. A symlink
across that boundary either doesn't resolve or syncs as a broken link file —
iCloud's Files provider doesn't handle symlinks reliably, particularly on
iOS. A plain copy has no such failure mode, at the cost of an explicit
push/pull step instead of it being automatic.

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| `$OBSIDIAN_VAULT_DIR is not set` | Add the export to `machines/$HOSTNAME/env.zsh` (or `local/env.zsh`) and open a new shell. |
| Daily-quote block throws in Obsidian | `customjs` plugin missing, or `Resources/Obsidian/Scripts/widgets.js` doesn't exist in this vault — that script isn't tracked here, only the template that calls it. |
| `tasks`/`dataview` code blocks render as raw text | Corresponding community plugin not installed in this vault. |
