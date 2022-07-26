#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing microk8s.bash"
    echo "PATH = $PATH"
fi

dashboard_token() {
    about 'display the current MicroK8s dashboard access token'
    group 'microk8s'
    local token

    token=$(sudo microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
    sudo microk8s kubectl -n kube-system describe secret "$token"
}
