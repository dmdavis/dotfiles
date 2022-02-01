#!/usr/bin/env bash

# Uncomment to debug .bash_profile
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Python 2.7.18 is still installed on DSM 6, as well.
export PYTHON_VERSION='3.8.6'

# Your place for hosting Git repos. I use this for private repos.
# TODO: Set this to NAS git
export GIT_HOSTING='git@github.com'

export BASH_IT_THEME=90210
# shellcheck source=./includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash

export PATH="/usr/local/mariadb10/bin/:$PATH"

# curl https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/lscolors.sh -o ~/.ls-colors.sh

# Set up LS_COLORS if present
if [[ -r "$HOME/.ls-colors.sh" ]]; then
    eval "$(dircolors "$HOME"/.ls-colors.sh)"
fi
