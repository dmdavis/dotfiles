#!/usr/bin/env bash

# Uncomment to debug .bashrc
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PYTHON_VERSION='3.8.10'
alias python=python3

# shellcheck source=./includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
