#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing work.profile.bash"
    echo "PATH = $PATH"
fi

# Uncomment to debug .bash_profile
#set -o xtrace

# Location of .files directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PYTHON_VERSION='3.9.10'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@github.com'

# Source Homebrew on M1
if [[ $(uname -m) == 'arm64' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set GOROOT to `/opt/homebrew/opt/go/libexec` rather than the
# `/opt/homebrew/Cellar/go/<version>/libexec path picked up by bash_it's
# go plugin.
GOROOT="$(brew --prefix golang)/libexec"
export GOROOT
export PATH="${GOROOT}/bin:$PATH"

# shellcheck source=./includes/bashit.bash
source "$BASEDIR"/includes/bashit.bash
# shellcheck source=./includes/work.bash
source "$BASEDIR"/includes/work.bash
# shellcheck source=./includes/mac.bash
source "$BASEDIR"/includes/mac.bash
# shellcheck source=./includes/minikube.bash
source "$BASEDIR"/includes/minikube.bash

alias llc='ll | lolcat'

export GEM_HOME="$HOME/.gems"
export GEM_PATH="$HOME/.gems"
export PATH="$GEM_PATH/bin:$PATH"

export WATCH_NAMESPACE=default
export ETCD_ENDPOINTS=127.0.0.1:32379  # When running in kind

# SSH shortcut
function ss() {
    ssh root@"$1"
}

# Can I get a little work done, please?
alias fucknetscope='sudo launchctl unload /Library/LaunchDaemons/com.netskope.stagentsvc.plist'
alias fuckvmware='sudo rm -rf /etc/paths.d/com.vmware.fusion.public'

# Contrail schema
export CONTRAIL_XML_SCHEMA_DIR='/Users/daled/Projects/contrail/contrail-api-client/schema'
export CONTRAIL_ALL_CFG_XSD="$CONTRAIL_XML_SCHEMA_DIR/all_cfg.xsd"
export CONTRAIL_YAML_SCHEMA_DIR='/Users/daled/go/src/contrail-config-ng/vnc-proxy/api'

# Contrail generateDS
export GENERATEDS_PYTHON_BIN='/Users/daled/.pyenv/versions/generateDS-2.7.17/bin/python'
export GENERATEDS_SCRIPT='/Users/daled/Projects/contrail/contrail-api-client/generateds/generateDS.py'
function generateDS() {
    ${GENERATEDS_PYTHON_BIN} ${GENERATEDS_SCRIPT} "$@"
}
function genDSgo() {
    generateDS -f -o "$1" -g golang-api ${CONTRAIL_ALL_CFG_XSD}
}
function genDSyml() {
    generateDS -f -o "${1:-${CONTRAIL_YAML_SCHEMA_DIR}}" -g contrail-json-schema ${CONTRAIL_ALL_CFG_XSD}
}

# Development host shortcuts
alias dev='ssh $DEV_USER@$DEV_HOST'
# Copy local file to dev VM
scpdev() {
  scp "$1" "$DEV_USER@$DEV_HOST:$2"
}
# Copy file from dev VM to local host
devscp() {
    if  [[ $1 == /* ]] ;
    then
        local COPY_PATH=$1
    else
        local COPY_PATH="$DEV_HOME_DIR/$1"
    fi
    scp "$DEV_USER@$DEV_HOST:$COPY_PATH" "${2:-.}"
}

# iTerm tmux to dev box
tmd() {
    it2prof tmux
    ssh -t "$DEV_USER@$DEV_HOST" 'tmux attach -t dev-vm || tmux -CC new -A -s dev-vm'
}

# iTerm tmux to NAS
#tmn() {
#    it2prof tmux-nas
#    # This won't work if /bin/bash isn't your default shell. Synology doesn't have
#    # chsh or usermod, but you can set it by editing /etc/passwd. It will be the
#    # last value on a user's row in that file.
#    ssh -p "$NAS_SSH_PORT" -t "$NAS_USER@$NAS_IP" bash -l -c 'tmux attach -t NAS-DS918-PLUS || tmux -CC new -A -s NAS-DS918-PLUS'
#}

# contrail-api-cli
#alias contrail-api-cli='/Users/daled/.pyenv/versions/contrail-api-cli-2.7.17/bin/contrail-api-cli'

#export PATH="$HOME/.cargo/bin:$PATH"

# Manually installed /usr/local/kubebuilder/bin
#export PATH=$PATH:/usr/local/kubebuilder/bin

# This `prev` function is from `pet : CLI Snippet Manager`
# https://github.com/knqyf263/pet#bash-prev-function
# shellcheck disable=SC2006,SC2001,SC2005,SC2046
function prev() {
    PREV=$(echo $(history | tail -n2 | head -n1) | sed 's/[0-9]* //')
    sh -c "pet new $(printf %q "$PREV")"
}

export PATH="${HOME}/bin:$PATH"
