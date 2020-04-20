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

# contrail-api-cli
alias contrail-api-cli='/Users/daled/.pyenv/versions/contrail-api-cli-2.7.17/bin/contrail-api-cli'

# Google CLI tools
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

export PATH="$HOME/.cargo/bin:$PATH"

# Manually installed /usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
