#!/usr/bin/env zsh

# Define these exports in .zshrc, not files checked into git.
export NAS_IP=''
export NAS_SSH_PORT=''
export NAS_USER=''

export NUC_IP=''
export NUC_SSH_PORT=''
export NUC_USER=''

export PI_HOLE_IP=''
export PI_HOLE_SSH_PORT=''
export PI_HOLE_USER=''

alias nas='ssh -p $NAS_SSH_PORT $NAS_USER@$NAS_IP'
alias nuc='ssh -p $NUC_SSH_PORT $NUC_USER@$NUC_IP'
alias pihole='ssh -p $PI_HOLE_SSH_PORT $PI_HOLE_USER@$PI_HOLE_IP'
alias pi-hole='ssh -p $PI_HOLE_SSH_PORT $PI_HOLE_USER@$PI_HOLE_IP'

# Copy a local file to a remote directory on the NAS
# Ex: cpnas ~/foo ~/
cpnas() {
    scp -P "$NAS_SSH_PORT" "$1" "$NAS_USER@$NAS_IP:$2"
}

# Copy a file on the NAS to a local directory
# Ex: nascp ~/.gitignore ~/
nascp() {
    scp -P "$NAS_SSH_PORT" "$NAS_USER@$NAS_IP:$1" "$2"
}
