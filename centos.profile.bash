#!/usr/bin/env bash

# Uncomment to debug .bash_profile
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PYTHON_VERSION='3.7.6'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@github.com'

# shellcheck source=./includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
# shellcheck source=./includes/work.bash
source "$BASEDIR"/includes/work.bash
# shellcheck source=./includes/dev-vms.bash
source "$BASEDIR"/includes/dev-vms.bash

# Add --color to common lso alias
alias llo='lso --color'

# Add --theme base16 to tldr (npm version) for color output
alias tldr='tldr -t base16'
