# `.zshenv' is sourced on all invocations of the shell, unless the -f option is
# set. It should contain commands to set the command search path, plus other
# important environment variables. `.zshenv' should not contain commands that
# produce output or assume the shell is attached to a tty.

# Which computer am I running on?
export HOSTNAME="$(hostname)"

# Location of dotfiles repo
export DOTFILES=${${(%):-%x}:A:h}

# Personal ~/bin folder
export PATH="$HOME/bin:$PATH"

# Dev-laptop (macOS) environment — Homebrew, Rust, mise. Skipped on the NAS / Linux.
[[ "$OSTYPE" == darwin* && -f "$DOTFILES/env.darwin.zsh" ]] && source "$DOTFILES/env.darwin.zsh"

# Hook: Machine profile environment (tracked configs)
[[ -f "$DOTFILES/machines/$HOSTNAME/env.zsh" ]] && source "$DOTFILES/machines/$HOSTNAME/env.zsh"