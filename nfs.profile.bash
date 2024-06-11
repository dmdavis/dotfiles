#!/usr/bin/env bash

if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing wsl.profile.bash"
    echo "PATH = $PATH"
fi

# Uncomment to debug .bashrc
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
# shellcheck source=./includes/ls-colors.bash
source "$BASEDIR"/includes/ls-colors.bash
