#!/usr/bin/env bash

if [[ $(command -v kubectl) != "" ]]; then
    alias kcaf='kubectl apply -f'
    alias kccf='kubectl create -f'
    alias kcd='kubectl describe'
    alias kced='kubectl edit'
    alias kcex='kubectl explain'
    alias kcl='kubectl logs'
    alias kclf='kubectl logs -f'
    alias kcv='kubectl version'

    if [[ "$OSTYPE" == "darwin"* ]]; then
        alias kcd4m="/Applications/Docker.app/Contents/Resources/bin/kubectl"
    fi
fi
