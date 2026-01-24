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

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"

# Rust
. "$HOME/.cargo/env"
export RUST_BACKTRACE=1
export RUST_LOG=info

# Personal ~/bin folder
export PATH="$HOME/bin:$PATH"
