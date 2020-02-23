#!/usr/bin/env bash

# Uncomment to debug .bash_profile
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PYTHON_VERSION='3.6.9'

# Your place for hosting Git repos. I use this for private repos.
# TODO: Set this to NAS git
export GIT_HOSTING='git@github.com'

# shellcheck source=$HOME/.files/includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
