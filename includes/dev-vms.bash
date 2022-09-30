#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing dev-vms.bash"
    echo "PATH = $PATH"
fi

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

export LOCAL_LOGFILE_FOLDER="$HOME/logs"

alias bz='bazelisk'
export BASE_TAG=''

# Change and display BASE_TAG
function basetag() {
    local old_tag
    if [ -z "$BASE_TAG" ]; then
        old_tag='empty string'
    else
        old_tag="$BASE_TAG"
    fi
    if [ -z "$1" ]; then
        if [ "$old_tag" != "$BASE_TAG" ]; then
            echo "BASE_TAG is not defined"
        else
            echo "BASE_TAG='$BASE_TAG'"
        fi
        return
    fi
    export BASE_TAG="$1"
    echo "BASE_TAG changed from $old_tag to $BASE_TAG"
}


function make_cn2() {
    local timestamp basetag
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    if [[ -z "${BASE_TAG}" ]]; then
        basetag='make'
    else
        basetag="$BASE_TAG-make"
    fi
    echo "Start time: $timestamp"
    time make HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" baseTag="$basetag" "$1" 2>&1 | tee "$LOCAL_LOGFILE_FOLDER/$basetag-$1-$timestamp.log.txt"
    echo "Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
}
alias mak='make_cn2'

export OPENSTACK_DEPLOYER='infra/deployer/default-deployer.json'
export AWS_DEPLOYER='infra/deployer/default-aws-deployer.json'
export ENABLE_TEARDOWN='false'

# ex. deploy single-cluster
# output: ~/single-cluster-deployment-2022-01-01_1200.log.txt
function deploy() {
    local timestamp runlog
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests" || return
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    runlog="$LOCAL_LOGFILE_FOLDER/$1-deployment-$timestamp.log.txt"
    echo "Deploying $1 FT flavor. Start time: $timestamp"
    time bazelisk run //tests:feature_tests_ci --stamp \
    --test_timeout=9000 --test_filter="fake" \
    --test_env=TEST_TIMEOUT=9000 \
    --test_env=HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" \
    --test_env=DEPLOYER_FLAVOR="$1" \
    --test_env=DEPLOYER_CONFIG="$OPENSTACK_DEPLOYER" \
    --test_env=ENABLE_TEARDOWN="$ENABLE_TEARDOWN" 2>&1 | tee "$runlog"
    echo "$1 deployed. Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
    echo "Run log located at $runlog"
    popd || return
}

# ex. bzl //ui/... --blah
# output: ~/bazelisk-2022-01-01_1200.log.txt
function bzl() {
    local timestamp runlog
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2" || return
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    runlog="$LOCAL_LOGFILE_FOLDER/bazelisk-$timestamp.log.txt"
    echo "Starting bazelisk: 'bzl $*'. Start time: $timestamp"
    time bazelisk "$@" 2>&1 | tee "$runlog"
    echo "Bazelisk complete: 'bzl $*'. Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
    echo "Run log located at $runlog"
    popd || return
}

# ex. ft single-cluster
# output: ~/single-cluster-ft-run-2022-01-01_1200.log.txt
function ft() {
    local timestamp runlog
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests" || return
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    runlog="$LOCAL_LOGFILE_FOLDER/$1-ft-run-$timestamp.log.txt"
    echo "Starting $1 feature tests. Start time: $timestamp"
    time bazelisk run //tests:feature_tests_ci --stamp \
    --test_timeout=9000 \
    --test_env=TEST_TIMEOUT=9000 \
    --test_env=HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" \
    --test_env=DEPLOYER_FLAVOR="$1" \
    --test_env=DEPLOYER_CONFIG="$OPENSTACK_DEPLOYER" \
    --test_env=ENABLE_TEARDOWN="$ENABLE_TEARDOWN" 2>&1 | tee "$runlog"
    echo "$1 feature tests complete. Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
    echo "Run log located at $runlog"
    popd || return
}

# ex. aws single-cluster
# output: ~/single-cluster-aws-run-2022-01-01_1200.log.txt
# Always tear down AWS machines cuz $$$
function aws() {
    local timestamp runlog
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests" || return
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    runlog="$LOCAL_LOGFILE_FOLDER/$1-aws-run-$timestamp.log.txt"
    echo "Starting $1 feature tests. Start time: $timestamp"
    time bazelisk run //tests:feature_tests_ci --stamp \
    --test_timeout=9000 \
    --test_env=TEST_TIMEOUT=9000 \
    --test_env=HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" \
    --test_env=DEPLOYER_FLAVOR="$1" \
    --test_env=DEPLOYER_CONFIG="$AWS_DEPLOYER" \
    --test_env=ENABLE_TEARDOWN=true 2>&1 | tee "$runlog"
    echo "$1 feature tests complete. Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
    echo "Run log located at $runlog"
    popd || return
}

# Deploy CN2 to minikube
function minikube_deploy_cn2() {
    # MINIKUBE_RUNTIME := cri-o
    # MINIKUBE_KUBEVERSION := 1.20.1
    # BASE_TAG := master-latest
    # ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
    # HOST_REGISTRY = $(HOST_IP):5000
    # REGISTRY = $(HOST_REGISTRY)/atom-docker/cn2/bazel-build/dev
    # INSECURE=true
    # MINIKUBE_INSECURE :=
    # MINIKUBE_INSECURE += --insecure-registry $(shell echo $(REGISTRY) | sed 's:/.*::')
    # MINIKUBE_DRIVER :=
    # MINIKUBE_DRIVER += --driver kvm  # on Linux
    # MINIKUBE_CONTRAIL_ISO_LATEST := minikube.iso
    # MINIKUBE_CONTRAIL_ISO_URL := https://svl-artifactory.juniper.net/artifactory/atom-static-dev/cn2/minikube/v1.19.0
    # MINIKUBE_ISO_URL := --iso-url=$(MINIKUBE_CONTRAIL_ISO_URL)/$(MINIKUBE_CONTRAIL_ISO_LATEST)
    # minikube start $(MINIKUBE_ISO_URL) $(MINIKUBE_DRIVER) $(MINIKUBE_INSECURE) --cni $(ROOT_DIR)/../deployer/manifests/kustomize/applier/custom/$(TAG)/minikube/deployer.yaml --container-runtime $(MINIKUBE_RUNTIME) --memory $(MINIKUBE_RAM) --cpus $(MINIKUBE_CPU) --kubernetes-version $(MINIKUBE_KUBEVERSION) --wait=all $(MINIKUBE_FORCE)
    local branch force
    branch=$(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD)
    if [ "$USER" == 'root' ]; then
        force='--force'
    else
        force=''
    fi
    minikube start \
        --iso-url=https://svl-artifactory.juniper.net/artifactory/atom-static-dev/cn2/minikube/v1.19.0/minikube.iso \
        --insecure-registry http://localhost:5000/atom-docker/cn2/bazel-build/dev \
        --cni "$CN2_PATH/deployer/manifests/kustomize/applier/custom/$branch/minikube/deployer.yaml" \
        --container-runtime cri-o --driver kvm --memory 16G --cpu 2 \
        --kubernetes-version 1.20.1 --wait=all "$force"
}
alias mkd='minikube_deploy_cn2'

# Clean CN2 development custom deployers
function clean_custom_deployers() {
    for f in ${CN2_PATH}/deployer/manifests/kustomize/applier/custom; do
        fuser -s "$f" || rm -rf "$f"
        echo "Deleted $f"
    done
}
alias ccd='clean_custom_deployers'

# Clean unopened files from $TMPDIR
function clean_temp_dir() {
    local filename
    for f in "$TMPDIR"/*; do
    filename=$(basename "$f")
        if [[ $filename = @(generate_bash_completion.sh|bazel-complete-template.bash|bazel-complete-header.bash|.bazeliskrc) ]]; then
            echo "Skipping $f"
        else
            fuser -s "$f" || rm -rf "$f"
            echo "Deleted $f"
        fi
    done
}
alias ctd='clean_temp_dir'

# Define this in your .bashrc
export ARTIFACTORY_HOST=""
export ARTIFACTORY_URL="https://${ARTIFACTORY_HOST}/artifactory"
export COMMON_PYPI_REMOTE="${ARTIFACTORY_URL}/api/pypi/pypi-remote/simple"

# Add Cargo, golang, and home directory /bin folders to PATH
export PATH=${HOME}/bin:${HOME}/go/bin:${HOME}/.cargo/bin:${PATH}

# Don't forget, nvim using .vimrc isn't automatic and not in ansadm yet.
# See https://neovim.io/doc/user/nvim.html#nvim-from-vim
alias v=nvim
