#!/usr/bin/env bash

# Default to a private repo running on localhost
export DOCKER_REPO_PORT=5000
export DOCKER_REPO_HOST='127.0.0.1'

# Build aliases
alias mba='time make build-all HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mda='time make deploy-all HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'

alias mfthacd='time make feature-tests-singleclusterHA-cd HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
#alias mfthadev='time make feature-tests-singlecluster-ha-dev HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT DEPLOYER_CONFIG=/home/daled/k8s.ha.json'
alias mfthadev='time make feature-tests-singlecluster-ha-dev HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'

alias mftocpdev='time make feature-tests-ocp-dev HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mftvrrpdev='time make feature-tests-ocp-vrrp-dev HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mftocpcd='time make feature-tests-ocp-cd HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'

alias mftsnci='time make feature-tests-singlenode-ci HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mftdpdkci='time make feature-tests-dpdk-ci HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'

export FT_TEST_YAML="$HOME/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests/tests/test-yaml"
export K8S_HOME="/home"

# Legacy; not used
export OCP_USER="${OCP_USER:-core}"
export OCP_HOME="/var/home"


# Override these in local .bashrc
export K8S_USER="${K8S_USER:-ubuntu}"
export K8S_LAB_NETWORK='127.0.0'
export K8S_PRIVATE_KEY="$HOME/id"

# args: private key path, user, ip/host
__ssh_lab() {
    echo "ssh -i $1 $2@$3"
    ssh -i "$1" "$2@$3"
}

# Shortcut for SSH'ing into k8s cluster nodes in OpenStack
k8ssh() {
    __ssh_lab "$K8S_PRIVATE_KEY" "$K8S_USER" "$K8S_LAB_NETWORK.$1"
}

# Copy k9s to test cluster (for one's that don't have it installed)
scpk9s() {
    echo "Copying k9s to $K8S_USER@$K8S_LAB_NETWORK.$1:$K8S_HOME/$K8S_USER/"
    scp -i "$K8S_PRIVATE_KEY" ~/local/bin/k9s "$K8S_USER@$K8S_LAB_NETWORK.$1:$K8S_HOME/$K8S_USER/"
}

# args: private key path, user, ip/host, home dir
__scp_test_yaml() {
    echo "Copying test yaml in $FT_TEST_YAML to $2@$3:$4/$2/"
    scp -i "$1" "$FT_TEST_YAML/snat-ext-ping-test-pod.yaml" "$2@$3:$4/$2/"
    scp -i "$1" "$FT_TEST_YAML/port-translation-test-pod.yaml" "$2@$3:$4/$2/"
}

k8sgetconfig() {
    scp -i "$K8S_PRIVATE_KEY" "$K8S_USER@$K8S_LAB_NETWORK.$1:$K8S_HOME/$K8S_USER/.kube/config" "$HOME/$K8S_LAB_NETWORK.$1.kubeconfig"
}

# Copy test yaml to test cluster
k8sscptestyaml() {
    __scp_test_yaml "$K8S_PRIVATE_KEY" "$K8S_USER" "$K8S_LAB_NETWORK.$1" "$K8S_HOME"
}

# Clean up dirty, bloated build directory.
offs_build() {
    pushd "$HOME/go/src/ssd-git.juniper.net/contrail/cn2/build" || return 1
    local git_ignore_entry
    while IFS="" read -r git_ignore_entry || [ -n "$git_ignore_entry" ]
    do
        echo "removing $git_ignore_entry"
        rm -rf "$git_ignore_entry"
    done < .gitignore
    popd || return 2
}

# Clean up sudo-installed gorp in Bazel's cache.
offs_bazel() {
    echo "Removing ~/.cache/bazel*"
    sudo rm -rf ~/.cache/bazel*
}
