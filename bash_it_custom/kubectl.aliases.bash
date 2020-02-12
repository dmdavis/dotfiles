#!/usr/bin/env bash

if [[ $(command -v kubectl) != "" ]]; then
    alias kcv="kubectl version"
    alias kcl="kubectl logs"
    alias kclf="kubectl logs -f"
fi