# Machine Profiles

This directory contains machine-specific configurations that ARE tracked in 
version control.

## When to use machine profiles vs. local/

**Use `machines/<hostname>/`** for:
- Configuration you want to share across fresh OS installations
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
   ```sh
   hostname
   ```

2. Create profile directory:
   ```sh
   mkdir -p "machines/$(hostname)"
   ```

3. Put environment variables that should load in [`.zshenv`](../.zshenv) in a 
   `machines/$(hostname)/env-pre.zsh` file. Be careful not to put commands
   in these files that produce output or assume the shell is attached to a tty. 

4. Add `.zsh` files:
   - Any `.zsh` files *not* named j`env.zsh` in the profile's folder will be 
     auto-sourced at the end of `.zshrc`.
   - Files are loaded in alphabetical order
   - Consider prefixing with numbers if order matters: `01-env.zsh`, 
     `02-aliases.zsh`, etc.

5. For untracked configs and sensitive data, create a `local/` subdirectory and
   put them in it:
   ```sh
   mkdir -p "machines/$(hostname)/local"
   ```
   Then you can source them from your files in `machines/$(hostname)`.
