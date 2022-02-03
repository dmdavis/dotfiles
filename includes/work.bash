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

# Short for SSH'ing into ocp-dev cluster nodes
ocpsh() {
    ssh -i ~/id_ocp_dev "core@10.87.88.$1"
}

# Copy k9s to test cluster
ocpscpk9s() {
    echo "Copying k9s to core@10.87.88.$1:/var/home/core/"
    scp -i ~/id_ocp_dev ~/local/bin/k9s "core@10.87.88.$1:/var/home/core/"
}

# Copy test yaml to test cluster
ocpscptestyaml() {
    echo "Copying snat-ext-ping-test-pod.yaml to core@10.87.88.$1:/var/home/core/"
    scp -i ~/id_ocp_dev ~/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests/tests/test-yaml/snat-ext-ping-test-pod.yaml "core@10.87.88.$1:/var/home/core/"
    scp -i ~/id_ocp_dev ~/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests/tests/test-yaml/port-translation-test.yaml "core@10.87.88.$1:/var/home/core/"
    scp -i ~/id_ocp_dev ~/go/src/ssd-git.juniper.net/contrail/cn2/feature_tests/tests/test-yaml/port-translation-test-ha.yaml "core@10.87.88.$1:/var/home/core/"
}
