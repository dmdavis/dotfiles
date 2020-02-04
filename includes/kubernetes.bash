#!/usr/bin/env bash

# Some stuff from my brief flirtation with minikube
# https://github.com/kubernetes/minikube
if [[ $(command -v minikube) != "" ]]; then
    export MINIKUBE_VM_DRIVER="virtualbox"

    function kcmk() {
        alias kubectl="minikube kubectl"
        msg "kubectl set to minikube kubectl'"
    }
    function kcrestore() {
        unalias kubectl
        msg "kubectl set to $(command -v kubectl)"
    }

    function mkstart() {
        minikube start --vm-driver=$MINIKUBE_VM_DRIVER --insecure-registry=0.0.0.0/0
        kcmk
    }
    function mkstop() {
        minikube stop
        kcrestore
    }
    function mkx() {
        minikube delete
        kcrestore
    }
fi
