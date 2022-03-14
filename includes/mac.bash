#!/usr/bin/env bash

export PATH="/usr/local/sbin:$PATH"
export EDITOR='nvim'

alias vim=nvim
alias v=nvim

shopt -u extdebug
# shellcheck source=../../.iterm2_shell_integration.bash
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Switch iTerm 2 profile from cli
# >> it2prof
function it2prof() {
    echo -e "\033]50;SetProfile=$1\a"
}

# Postgres.app CLI tools
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"

# Fix broken PROMPT_COMMAND
export PROMPT_COMMAND='__bp_precmd_invoke_cmd; _pyenv_virtualenv_hook; _direnv_hook; autojump_add_to_database; __bp_interactive_mode'

export CDPATH=".:$HOME"

# Add NAS_SSH_PORT to .bashrc (Don't store in public repos)
# export NAS_SSH_PORT=xxxx
