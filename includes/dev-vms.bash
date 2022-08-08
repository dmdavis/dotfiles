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

export OPENSTACK_DEPLOYER='infra/deployer/default-deployer.json'
export AWS_DEPLOYER='infra/deployer/default-aws-deployer.json'

# ex. deploy single-cluster
# output: ~/single-cluster-deployment-2022-01-01_1200.log.txt
function deploy() {
    local timestamp runlog
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests" || return
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    runlog="$HOME/$1-deployment-$timestamp.log.txt"
    echo "Deploying $1 FT flavor. Start time: $timestamp"
    time bazelisk run //tests:feature_tests_ci --stamp \
    --test_timeout=9000 --test_filter="fake" \
    --test_env=TEST_TIMEOUT=9000 \
    --test_env=HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" \
    --test_env=DEPLOYER_FLAVOR="$1" \
    --test_env=DEPLOYER_CONFIG="$OPENSTACK_DEPLOYER" \
    --test_env=ENABLE_TEARDOWN=false  2>&1 | tee "$runlog"
    echo "$1 deployed. Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
    echo "Run log located at $runlog"
    popd || return
}

# ex. ft single-cluster
# output: ~/single-cluster-ft-run-2022-01-01_1200.log.txt
function ft() {
    local timestamp runlog
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests" || return
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    runlog="$HOME/$1-ft-run-$timestamp.log.txt"
    echo "Starting $1 feature tests. Start time: $timestamp"
    time bazelisk run //tests:feature_tests_ci --stamp \
    --test_timeout=9000 \
    --test_env=TEST_TIMEOUT=9000 \
    --test_env=HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" \
    --test_env=DEPLOYER_FLAVOR="$1" \
    --test_env=DEPLOYER_CONFIG="$OPENSTACK_DEPLOYER" \
    --test_env=ENABLE_TEARDOWN=false  2>&1 | tee "$runlog"
    echo "$1 feature tests complete. Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
    echo "Run log located at $runlog"
    popd || return
}

# ex. aws single-cluster
# output: ~/single-cluster-aws-run-2022-01-01_1200.log.txt
function aws() {
    local timestamp runlog
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests" || return
    timestamp="$(date +'%Y-%m-%d_%H%M')"
    runlog="$HOME/$1-aws-run-$timestamp.log.txt"
    echo "Starting $1 feature tests. Start time: $timestamp"
    time bazelisk run //tests:feature_tests_ci --stamp \
    --test_timeout=9000 \
    --test_env=TEST_TIMEOUT=9000 \
    --test_env=HOST_REGISTRY="$DOCKER_REPO_HOST:$DOCKER_REPO_PORT" \
    --test_env=DEPLOYER_FLAVOR="$1" \
    --test_env=DEPLOYER_CONFIG="$AWS_DEPLOYER" \
    --test_env=ENABLE_TEARDOWN=true  2>&1 | tee "$runlog"
    echo "$1 feature tests complete. Start time: $timestamp, end time: $(date +'%Y-%m-%d_%H%M')"
    echo "Run log located at $runlog"
    popd || return
}

# Define this in your .bashrc
export ARTIFACTORY_HOST=""
export ARTIFACTORY_URL="https://${ARTIFACTORY_HOST}/artifactory"
export COMMON_PYPI_REMOTE="${ARTIFACTORY_URL}/api/pypi/pypi-remote/simple"

export PATH=${HOME}/bin:${HOME}/go/bin:${PATH}
