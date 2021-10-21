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
# shellcheck source=./includes/kubectl.contrail.aliases.bash
source "$BASEDIR"/includes/kubectl.contrail.aliases.bash

# kubectl aliases for feature-tests clusters
if [[ $(command -v kubectl) != "" ]]; then
    alias kcaf2='kubectl --kubeconfig ~/.kube/kubeconfig apply -f'
    alias kccf2='kubectl --kubeconfig ~/.kube/kubeconfig create -f'
    alias kcd2='kubectl --kubeconfig ~/.kube/kubeconfig describe'
    alias kced2='kubectl --kubeconfig ~/.kube/kubeconfig edit'
    alias kcex2='kubectl --kubeconfig ~/.kube/kubeconfig explain'
    alias kcl2='kubectl --kubeconfig ~/.kube/kubeconfig logs'
    alias k9s2='k9s --kubeconfig ~/.kube/kubeconfig'
fi

# Copy dev VM file to Macbook
scpmac() {
  scp "$1" "$MAC_USER@$MAC_HOST:$2"
}

# Oh, for fuck's sake, Dev VM Docker. Out of space AGAIN?
offs() {
    if [ -n "$(docker ps -q -a -f name=registry)" ];
    then
        docker stop registry
        docker rm -v registry
    fi
    sudo docker system prune -a -f --volumes
    docker run -d -p 5000:5000 --restart=always --name registry svl-artifactory.juniper.net/atom-docker/cn2/registry:2
}

# Copy file from Macbook to dev VM
macscp() {
    if  [[ $1 == /* ]] ;
    then
        local COPY_PATH=$1
    else
        local COPY_PATH="$MAC_HOME_DIR/$1"
    fi
    scp "$MAC_USER@$MAC_HOST:$COPY_PATH" "${2:-.}"
}

# Add --color to common lso alias
alias llo='lso --color'
