#!/usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Prevent `brew doctor` from freaking out over python-configs in ~/.pyenv
    alias brew='env PATH=${PATH//$(pyenv root)\/shims:/} brew'

    # Custom brew aliases
    alias bubo='brew update && brew outdated'
    alias bubc='brew upgrade && brew cleanup'
fi
