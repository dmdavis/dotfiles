#!/usr/bin/env bash

if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing kubectl.bash"
    echo "PATH = $PATH"
fi

alias kcx='kubectl exec -it'
