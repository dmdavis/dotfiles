#!/usr/bin/env bash

# Uncomment to debug .bash_profile
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PYTHON_VERSION='3.7.6'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@github.com'

# shellcheck source=$HOME/.files/includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
# shellcheck source=$HOME/.files/includes/mac.bash
source "$BASEDIR"/includes/mac.bash
# shellcheck source=$HOME/.files/includes/minikube.bash
source "$BASEDIR"/includes/minikube.bash
# shellcheck source=$HOME/.files/includes/kubectl.contrail.aliases.bash
source "$BASEDIR"/includes/kubectl.contrail.aliases.bash

alias llc='ll | lolcat'

export GEM_HOME="$HOME/.gems"
export GEM_PATH="$HOME/.gems"
export PATH="$GEM_PATH/bin:$PATH"

export WATCH_NAMESPACE=default
export ETCD_ENDPOINTS=127.0.0.1:32379

# SSH shortcut
function ss() {
    ssh root@"$1"
}

# Can I get a little work down, please?
alias fucknetscope='sudo launchctl unload /Library/LaunchDaemons/com.netskope.stagentsvc.plist'

# Google CLI tools
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

export PATH="$HOME/.cargo/bin:$PATH"
