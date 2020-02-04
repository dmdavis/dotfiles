#!/usr/bin/env bash

if [[ $(command -v kubectl) != "" ]]; then
    alias kcv="kubectl version"
    alias kcgp="kubectl get pods"
fi