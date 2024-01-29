#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing nuc10.profile.bash"
    echo "PATH = $PATH"
fi

# Uncomment to debug .bashrc
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

alias python=python3
alias ipython=ipython3

# Your place for hosting Git repos. I use this for private repos.
# TODO: Set this to NAS git
export GIT_HOSTING='git@github.com'

# shellcheck source=./includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
# shellcheck source=./includes/microk8s.bash
source "$BASEDIR"/includes/microk8s.bash
# shellcheck source=./includes/ubuntu.bash
source "$BASEDIR"/includes/ubuntu.bash
# shellcheck source=./includes/ls-colors.bash
source "$BASEDIR"/includes/ls-colors.bash