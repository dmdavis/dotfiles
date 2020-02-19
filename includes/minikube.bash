#!/usr/bin/env bash

# Some stuff from my brief flirtation with minikube
# https://github.com/kubernetes/minikube
if [[ $(command -v minikube) != "" ]]; then

    export MINIKUBE_VM_DRIVER="virtualbox"
    export MINIKUBE_VM_CPUS=4
    export MINIKUBE_VM_RAM="8192mb"     # 8Gb
    export MINIKUBE_VM_DISK_SIZE="60g"  # 60Gb

    alias mkstop="minikube stop"
    alias mkstart="minikube start"
    alias mkx="minikube delete"

    function mkcc() {
        echo "Creating minikube cluster with local Docker registry pod"
        minikube start \
            --cpus=$MINIKUBE_VM_CPUS \
            --memory=$MINIKUBE_VM_RAM \
            --disk-size=$MINIKUBE_VM_DISK_SIZE \
            --vm-driver=$MINIKUBE_VM_DRIVER \
            --addons registry \
            --insecure-registry "10.0.0.0/24"
    }

    function mkx() {
        minikube delete
    }

    function dkmkreg() {
        echo "Redirecting Docker for Mac port 5000 to minikube port 5000. Hit CTRL-C to quit."
        docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
    }

fi
