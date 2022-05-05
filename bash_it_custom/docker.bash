#!/usr/bin/env bash

if [[ $(command -v docker) != "" ]]; then
    export REG_IMAGE_PATH="${REG_IMAGE_PATH:-}"

    # Prints 'true' and returns 0 if running, else returns non-zero
    function dkcrunning() {
        docker inspect -f '{{.State.Running}}' "$@" 2>/dev/null
    }

    # Local Docker registry server commands
    # See https://docs.docker.com/registry/deploying/
    function dkregup() {
        if [ "$(dkcrunning registry)" = 'true' ]; then
            echo "Registry already running."
        else
            echo "Creating local Docker registry at 127.0.0.1:5000"
            docker run -d -p 5000:5000 --restart=always --name registry "$REG_IMAGE_PATH"registry:2
        fi
    }
    function dkregdown() {
        echo "Stopping and removing Docker registry container"
        docker container stop registry && docker container rm -v registry
    }

fi
