#!/usr/bin/env bash

# Uncomment to debug .bash_profile
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PYTHON_VERSION='3.5.1'

# shellcheck source=$HOME/.files/includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
