#!/usr/bin/env bash

# Uncomment to debug .bash_profile
#set -o xtrace

export PYTHON_VERSION='3.7.4'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@github.com'

source ./includes/bashit.bash
source ./includes/mac.bash

alias llc='ll | lolcat'

export GEM_HOME="$HOME/.gems"
export GEM_PATH="$HOME/.gems"
export PATH="$GEM_PATH/bin:$PATH"

# SSH shortcut
function ss {
  ssh root@"$1"
}

# Google CLI tools
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

export PATH="$HOME/.cargo/bin:$PATH"


