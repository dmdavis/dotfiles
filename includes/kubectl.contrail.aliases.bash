#!/usr/bin/env bash

# kubectl aliases for Contrail config CRDs
if [[ $(command -v kubectl) != "" ]]; then
    alias kcdri="kubectl describe routinginstance"
    alias kceri="kubectl edit routinginstance"
    alias kcevn="kubectl edit virtualnetwork"
fi