#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing ubuntu.profile.bash"
    echo "PATH = $PATH"
fi

# Uncomment to debug .bashrc
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PYTHON_VERSION='3.10.4'

# Your place for hosting Git repos. I use this for private repos.
# TODO: Set this to NAS git
export GIT_HOSTING='git@github.com'

# shellcheck source=./includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
# shellcheck source=./includes/work.bash
source "$BASEDIR"/includes/work.bash
# shellcheck source=./includes/ubuntu.bash
source "$BASEDIR"/includes/ubuntu.bash
# shellcheck source=./includes/dev-vms.bash
source "$BASEDIR"/includes/dev-vms.bash
