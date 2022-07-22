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

# kubectl aliases for feature-tests clusters
if [[ $(command -v kubectl) != "" ]]; then
    alias kcaf2='kubectl --kubeconfig ~/.kube/kubeconfig apply -f'
    alias kccf2='kubectl --kubeconfig ~/.kube/kubeconfig create -f'
    alias kcd2='kubectl --kubeconfig ~/.kube/kubeconfig describe'
    alias kced2='kubectl --kubeconfig ~/.kube/kubeconfig edit'
    alias kcex2='kubectl --kubeconfig ~/.kube/kubeconfig explain'
    alias kcl2='kubectl --kubeconfig ~/.kube/kubeconfig logs'
    alias k9s2='k9s --kubeconfig ~/.kube/kubeconfig'
    alias kcafocp='kubectl --kubeconfig /tmp/ocpcluster apply -f'
    alias kccfocp='kubectl --kubeconfig /tmp/ocpcluster create -f'
    alias kcdocp='kubectl --kubeconfig /tmp/ocpcluster describe'
    alias kcedocp='kubectl --kubeconfig /tmp/ocpcluster edit'
    alias kcexocp='kubectl --kubeconfig /tmp/ocpcluster explain'
    alias kclocp='kubectl --kubeconfig /tmp/ocpcluster logs'
    alias k9socp='k9s --kubeconfig /tmp/ocpcluster'
fi

# Copy dev VM file to Macbook
scpmac() {
    scp "$1" "$MAC_USER@$MAC_HOST:$2"
}

export REG_IMAGE_PATH="svl-artifactory.juniper.net/atom-docker/cn2/"

# Oh, for fuck's sake, Dev VM Docker. Out of space AGAIN?
offs() {
    if [ -n "$(docker ps -q -a -f name=registry)" ]; then
        docker stop registry
        docker rm -v registry
    fi
    sudo docker system prune -a -f --volumes
    docker run -d -p 5000:5000 --restart=always --name registry "$REG_IMAGE_PATH"registry:2
}

# Copy file from Macbook to dev VM
macscp() {
    if [[ $1 == /* ]]; then
        local COPY_PATH=$1
    else
        local COPY_PATH="$MAC_HOME_DIR/$1"
    fi
    scp "$MAC_USER@$MAC_HOST:$COPY_PATH" "${2:-.}"
}

# Add --color to common lso alias
alias llo='lso --color'

# Add --theme base16 to tldr (npm version) for color output
alias tldr='tldr -t base16'

alias bz='bazelisk'
export BASE_TAG=''
function mk() {
    local timestamp basetag
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    if [[ -z "${BASE_TAG}" ]]; then
        basetag='make'
    else
        basetag="$BASE_TAG-make"
    fi
    echo "Start time: $timestamp"
    time make HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" baseTag="$BASE_TAG" "$1" 2>&1 | tee "$HOME/$basetag-$1-$timestamp.log.txt"
    echo "Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
}

# ex. deploy single-cluster
function deploy() {
    local timestamp
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests" || return
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    echo "Start time: $timestamp"
    time bazelisk run //tests:feature_tests_ci --stamp \
    --test_timeout=9000 --test_filter="fake" \
    --test_env=TAG="$BASE_TAG" \
    --test_env=TEST_TIMEOUT=9000 \
    --test_env=HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" \
    --test_env=DEPLOYER_FLAVOR="$1" \
    --test_env=DEPLOYER_CONFIG=infra/deployer/default-deployer.json \
    --test_env=ENABLE_TEARDOWN=false
    echo "Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
    popd || return
}
