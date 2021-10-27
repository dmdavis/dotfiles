#!/usr/bin/env bash

cite about-plugin
about-plugin 'Helpers to more easily work with krew'

krew-install() {
    about 'install krew (kubectl plugin manager)'
    group 'krew'

    local OS
    local ARCH
    local KREW

    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
    KREW="krew-${OS}_${ARCH}"

    pushd "$(mktemp -d)" || return 1
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" || return 2
    tar zxvf "${KREW}.tar.gz" || return 3
    ./"${KREW}" install krew
    popd || return 4
}

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
