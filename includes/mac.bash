#!/usr/bin/env bash

export PATH="/usr/local/sbin:$PATH"
export EDITOR='nvim'

alias vim=nvim
alias v=nvim

shopt -u extdebug
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
# Switch iTerm 2 profile from cli

# Switch iTerm2 profile
# >> it2prof
function it2prof {
    echo -e "\033]50;SetProfile=$1\a"
}

# Postgres.app CLI tools
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"

# Add NAS_SSH_PORT to .bash_profile (Don't store in public repos)
# export NAS_SSH_PORT=xxxx