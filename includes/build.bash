#!/usr/bin/env bash

# Default to a private repo running on localhost
export DOCKER_REPO_PORT=5000
export DOCKER_REPO_HOST='127.0.0.1'

# Build aliases
alias mba='time make build-all HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mda='time make deploy-all HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'

alias mfthacd='time make feature-tests-singleclusterHA-cd HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mfthadev='time make feature-tests-singlecluster-ha-dev HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT DEPLOYER_CONFIG=/home/daled/k8s.ha.json'

alias mftocpdev='time make feature-tests-ocp-dev HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mftvrrpdev='time make feature-tests-ocp-vrrp-dev HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mftocpcd='time make feature-tests-ocp-cd HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'

alias mftsnci='time make feature-tests-singlenode-ci HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
alias mftdpdkci='time make feature-tests-dpdk-ci HOST_REGISTRY=$DOCKER_REPO_HOST:$DOCKER_REPO_PORT'
