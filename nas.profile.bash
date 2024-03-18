#!/usr/bin/env bash

# Uncomment to debug .bash_profile
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Python 2.17.18 is still installed on DSM 7 under /usr/local/bin
# export PYTHON_VERSION='2.17.18'

# Python 3.8.12 is the default DSM 7 Python
# export PYTHON_VERSION='3.8.12'

# Python 3.11.5 is installed via SynoCommunity
export PYTHON_VERSION='3.11.5'

# Your place for hosting Git repos. I use this for private repos.
# TODO: Set this to NAS git
export GIT_HOSTING='git@github.com'

export BASH_IT_THEME=90210
# shellcheck source=./includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
# shellcheck source=./includes/ls-colors.bash
source "$BASEDIR"/includes/ls-colors.bash

export PATH="$HOME/bin:$PATH"
export SHELL='/bin/bash'

alias python3=python3.11
alias python=python3.11
alias py=python3.11
alias vim=/usr/local/bin/vim

# Local autojump built from source.
[[ -s /var/services/homes/dale/.autojump/etc/profile.d/autojump.sh ]] && source /var/services/homes/dale/.autojump/etc/profile.d/autojump.sh

