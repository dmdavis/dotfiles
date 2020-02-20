#!/usr/bin/env bash

if [[ $(command -v kubectl) != "" ]]; then
    alias kcv="kubectl version"
    alias kcl="kubectl logs"
    alias kclf="kubectl logs -f"
    alias kcd="kubectl describe"
    alias kccf="kubectl create -f"
    alias kce="kubectl edit"
fi