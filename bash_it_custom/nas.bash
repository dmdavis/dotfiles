#!/usr/bin/env bash

# Define these exports in .bashrc, not files checked into git.
export NAS_IP=''
export NAS_SSH_PORT=''
export NAS_USER=''

alias nas='ssh -p $NAS_SSH_PORT $NAS_USER@$NAS_IP'

# Copy a local file to a remote directory on the NAS
# Ex: cpnas ~/foo ~/
function cpnas() {
    scp -P "$NAS_SSH_PORT" "$1" "$NAS_USER@$NAS_IP:$2"
}

# Copy a file on the NAS to a local directory
# Ex: nascp ~/.gitignore ~/
function nascp() {
    scp -P "$NAS_SSH_PORT" "$NAS_USER@$NAS_IP:$1" "$2"
}
