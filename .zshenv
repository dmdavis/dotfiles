# `.zshenv' is sourced on all invocations of the shell, unless the -f option is
# set. It should contain commands to set the command search path, plus other important
# environment variables. `.zshenv' should not contain commands that produce output
# or assume the shell is attached to a tty.

# Which computer am I running on?
export HOSTNAME="$(hostname)"

# Location of dotfiles repo
export DOTFILES=${${(%):-%x}:A:h}

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Rust
. "$HOME/.cargo/env"
export RUST_BACKTRACE=1
export RUST_LOG=info

# Personal ~/bin folder
export PATH="$HOME/bin:$PATH"

# Hook: Early environment customization (before anything else)
# Use this for PATH modifications, early exports, etc.
[[ -f "$DOTFILES/local/env-pre.zsh" ]] && source "$DOTFILES/local/env-pre.zsh"

# Hook: Machine profile environment (tracked configs)
[[ -f "$DOTFILES/machines/$HOSTNAME/env.zsh" ]] && source "$DOTFILES/machines/$HOSTNAME/env.zsh"

# Hook: Machine-specific local environment (untracked configs)
[[ -f "$DOTFILES/machines/$HOSTNAME/local/env.zsh" ]] && source "$DOTFILES/machines/$HOSTNAME/local/env.zsh"
