#!/usr/bin/env bash

# Some stuff from my brief flirtation with minikube
# https://github.com/kubernetes/minikube
if [[ $(command -v minikube) != "" ]]; then

    export MINIKUBE_VM_DRIVER="virtualbox"
    export MINIKUBE_CPUS=4
    export MINIKUBE_MEMORY="8192mb"  # 8Gb
    export MINIKUBE_DISK_SIZE="60g"  # 60Gb

    function delete_minikube_ip_from_known_hosts() {
        mk_ip="$(minikube ip)"
        msg "Deleting minikube IP $mk_ip from ~/.ssh/known_hosts"
        ssh-keygen -R "$mk_ip"
    }

    alias mk="minikube"
    alias mkip="minikube ip"
    alias mkdash="minikube dashboard"
    alias mkstat="minikube status"
    alias mkv="minikube version"
    alias mkdke="minikube -p minikube docker-env"

    function mkdke_activate() {
        eval "$(minikube -p minikube docker-env)"
        msg "Docker now configured to use minikube"
    }

    function mkstart() {
        msg "Creating minikube cluster"
        minikube start --insecure-registry "10.0.0.0/24"
        msg "Enabling minikube Docker registry on $(minikube ip):5000"
        minikube addons enable registry
        mkdke_activate
    }

    function mkstop() {
        delete_minikube_ip_from_known_hosts
        msg "Stopping minikube cluster"
        minikube stop
    }

    function mkx() {
        delete_minikube_ip_from_known_hosts
        msg "Deleting minikube cluster"
        minikube delete
    }

    # If you want to run Docker for Mac and have `docker push` use the registry
    # running in minikube, run the following function in another terminal window.
    function redirect_5000() {
        msg "Redirecting Docker for Mac port 5000 to minikube port 5000. Hit CTRL-C to quit."
        docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
    }

fi
