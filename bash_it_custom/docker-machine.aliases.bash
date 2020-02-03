#!/usr/bin/env bash

if [[ $(command -v docker-machine) != "" ]]; then
    export VIRTUALBOX_CPU_COUNT=4      # 4 cpu cores
    export VIRTUALBOX_MEMORY=4096      # 4Gb RAM
    export VIRTUALBOX_DISK_SIZE=61440  # 60Gb Disk
    export VIRTUALBOX_DOCKER_MACHINE_VM_NAME="docker-machine-vm"

    alias dmls="docker-machine ls"
    alias dmcr="docker-machine create"
    alias dmcrvb='docker-machine create -d virtualbox --virtualbox-cpu-count $VIRTUALBOX_CPU_COUNT --virtualbox-memory $VIRTUALBOX_MEMORY --virtualbox-disk-size $VIRTUALBOX_DISK_SIZE $VIRTUALBOX_DOCKER_MACHINE_VM_NAME'
fi