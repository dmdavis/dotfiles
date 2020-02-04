#!/usr/bin/env bash

if [[ $(command -v docker-machine) != "" ]]; then
    function dmenv() {
        env | grep '^DOCKER\S*'
    }
    # TODO: Add argument to allow specify machines other than "default"
    function dendm() {
        eval "$(docker-machine env "$VIRTUALBOX_DOCKER_MACHINE_VM_NAME")"
        msg "Docker environment configured for Docker Machine"
        dmenv
    }
    function dendfm() {
        # shellcheck disable=SC2086
        unset ${!DOCKER_*}
        msg "Docker environment configured for Docker for Mac"
    }
fi
