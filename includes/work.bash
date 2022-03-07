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
export OCP_USER="${OCP_USER:-core}"
export OCP_HOME="/var/home"
export K8S_USER="${K8S_USER:-centos}"
export K8S_HOME="/home"

# Override these in local .bashrc
export OCP_LAB_NETWORK='127.0.0'
export K8S_LAB_NETWORK='127.0.0'
export OCP_PRIVATE_KEY="$HOME/id"
export K8S_PRIVATE_KEY="$HOME/id"

# args: private key path, user, ip/host
__ssh_lab() {
    ssh -i "$1" "$2@$3"
}

# Shortcut for SSH'ing into ocp-dev cluster nodes
ocpsh() {
    __ssh_lab "$OCP_PRIVATE_KEY" "$OCP_USER" "$OCP_LAB_NETWORK.$1"
}

# Shortcut for SSH'ing into k8s ha cluster nodes in ocp pool
k8ssh() {
    __ssh_lab "$K8S_PRIVATE_KEY" "$K8S_USER" "$K8S_LAB_NETWORK.$1"
}

# Copy k9s to test cluster
ocpscpk9s() {
    echo "Copying k9s to $OCP_USER@$OCP_LAB_NETWORK.$1:$OCP_HOME/$OCP_USER/"
    scp -i "$OCP_PRIVATE_KEY" ~/local/bin/k9s "$OCP_USER@$OCP_LAB_NETWORK.$1:$OCP_HOME/$OCP_USER/"
}

# args: private key path, user, ip/host, home dir
__scp_test_yaml() {
    echo "Copying test yaml in $FT_TEST_YAML to $2@$3:$4/$2/"
    scp -i "$1" "$FT_TEST_YAML/snat-ext-ping-test-pod.yaml" "$2@$3:$4/$2/"
    scp -i "$1" "$FT_TEST_YAML/port-translation-test-pod.yaml" "$2@$3:$4/$2/"
}

# Copy test yaml to test cluster
ocpscptestyaml() {
    __scp_test_yaml "$OCP_PRIVATE_KEY" "$OCP_USER" "$OCP_LAB_NETWORK.$1" "$OCP_HOME"
}
k8sscptestyaml() {
    __scp_test_yaml "$K8S_PRIVATE_KEY" "$K8S_USER" "$K8S_LAB_NETWORK.$1" "$K8S_HOME"
}
