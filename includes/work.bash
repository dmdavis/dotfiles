#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing work.bash"
    echo "PATH = $PATH"
fi

# Default to a private repo running on localhost
export DOCKER_REPO_PORT=5000
export DOCKER_REPO_HOST='127.0.0.1'

# Feature tests config
export CN2_PATH="$HOME/go/src/ssd-git.juniper.net/contrail/cn2"
export FT_PATH="$CN2_PATH/feature_tests"
export FT_TEST_YAML="$FT_PATH/tests/test-yaml"
export LAB_PRIVATE_KEY="$FT_PATH/infra/deployer/ci/keys/ftvm_rsa"

# Lab users and home folder paths for various FT cluster flavors
export OCP_USER="${OCP_USER:-core}"
export OCP_HOME="${OCP_HOME:-/var/home}"
#export OCP_NETWORK="10.87.89"
export OCP_NETWORK="10.87.88"
export K8S_USER="${K8S_USER:-ubuntu}"
export K8S_HOME="${K8S_HOME:-/home}"
export K8S_NETWORK="10.87.88"

# Initially default to ocp flavors
export LAB_USER="${LAB_USER:-core}"
export LAB_HOME="${LAB_HOME:-/var/home}"
export LAB_NETWORK="${LAB_NETWORK:-10.87.88}"

k8suconf() {
    echo "LAB_USER        = $LAB_USER"
    echo "LAB_HOME        = $LAB_HOME"
    echo "LAB_NETWORK     = $LAB_NETWORK"
    echo "LAB_PRIVATE_KEY = $LAB_PRIVATE_KEY"
}

k8socp() {
    export LAB_USER="$OCP_USER"
    export LAB_HOME="$OCP_HOME"
    export LAB_NETWORK="$OCP_NETWORK"
    echo "k8s helper functions set for OCP clusters"
    k8suconf
}

k8sk8s() {
    export LAB_USER="$K8S_USER"
    export LAB_HOME="$K8S_HOME"
    export LAB_NETWORK="$K8S_NETWORK"
    echo "k8s helper functions set for native k8s clusters"
    k8suconf
}

# args: private key path, user, ip/host
__ssh_lab() {
    echo "ssh -i $1 $2@$3"
    ssh -i "$1" "$2@$3"
}

# Shortcut for SSH'ing into k8s cluster nodes in OpenStack
k8ssh() {
    # TODO Add arg check
    __ssh_lab "$LAB_PRIVATE_KEY" "$LAB_USER" "$LAB_NETWORK.$1"
}

# Copy k9s to test cluster (for one's that don't have it installed)
scpk9s() {
    # TODO Add arg check
    echo "Copying k9s to $LAB_USER@$LAB_NETWORK.$1:$LAB_HOME/$LAB_USER/"
    scp -i "$LAB_PRIVATE_KEY" ~/.local/bin/k9s "$LAB_USER@$LAB_NETWORK.$1:$LAB_HOME/$LAB_USER/"
}

# args: private key path, user, ip/host, home dir
__scp_test_yaml() {
    echo "Copying test yaml in $FT_TEST_YAML to $2@$3:$4/$2/"
    scp -i "$1" "$FT_TEST_YAML/snat-ext-ping-test-pod.yaml" "$2@$3:$4/$2/"
    scp -i "$1" "$FT_TEST_YAML/port-translation-test-pod.yaml" "$2@$3:$4/$2/"
}

k8sgetconfig() {
    # TODO Add arg check
    scp -i "$LAB_PRIVATE_KEY" "$LAB_USER@$LAB_NETWORK.$1:$LAB_HOME/$LAB_USER/.kube/config" "$HOME/$LAB_NETWORK.$1.kubeconfig"
    echo "Copied $LAB_NETWORK.$1:$LAB_HOME/$LAB_USER/.kube/config to $HOME/$LAB_NETWORK.$1.kubeconfig"
}

# Copy test yaml to test cluster
k8sscptestyaml() {
    # TODO Add arg check
    __scp_test_yaml "$LAB_PRIVATE_KEY" "$LAB_USER" "$LAB_NETWORK.$1" "$LAB_HOME"
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

offs_webui() {
    local path
    path="${HOME}/go/src/ssd-git.juniper.net/contrail/cn2/ui/web/node_modules/"
    echo "Cleaning up ${path}"
    rm -rf "$path"
}

export CN2_PYENV_BIN="${PYENV_ROOT}/versions/cn2-3.10/bin"

# Contrail schema
export CONTRAIL_XML_SCHEMA_DIR="${HOME}/go/src/ssd-git.juniper.net/contrail/cn2/src/contrail-api-client/schema"
export CONTRAIL_ALL_CFG_XSD="$CONTRAIL_XML_SCHEMA_DIR/all_cfg.xsd"

# Contrail generateDS
export GENERATEDS_PYTHON="${CN2_PYENV_BIN}/python"
export GENERATEDS_SCRIPT="${HOME}/go/src/ssd-git.juniper.net/contrail/cn2/src/contrail-api-client/generateds/generateDS.py"

function generateDS() {
    ${GENERATEDS_PYTHON} "${GENERATEDS_SCRIPT}" "$@"
}
function genDSgo() {
    generateDS -f -o "$1" -g golang-api "${CONTRAIL_ALL_CFG_XSD}"
}

alias kcco='kubectl config'