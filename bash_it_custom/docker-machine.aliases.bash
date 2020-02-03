#!/usr/bin/env bash

if [[ $(command -v docker-machine) != "" ]]; then
    alias dmls="docker-machine ls"
    alias dmcr="docker-machine create"
fi
