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
# shellcheck source=./includes/ls-colors.bash
source "$BASEDIR"/includes/ls-colors.bash

export PATH="$HOME/bin:/usr/local/mariadb10/bin/:$PATH"
export SHELL='/bin/bash'

alias py='python3'

export GITLAB_HOME='/volume1/docker/volumes/gitlab-ce'

# Local autojump built from source.
[[ -s /var/services/homes/dale/.autojump/etc/profile.d/autojump.sh ]] && source /var/services/homes/dale/.autojump/etc/profile.d/autojump.sh
