#!/usr/bin/env bash

if [[ $(command -v docker-machine) != "" ]]; then
    function dmenv() {
        env | grep DOCKER
    }
    # TODO: Add argument to allow specify machines other than "default"
    function dendm() {
        eval "$(docker-machine env default)"
        msg "Environment configured for Docker Machine"
        dmenv
    }
    function dendfm() {
        unset "${!DOCKER_*}"
        msg "Environment configured for Docker for Mac"
    }
fi
