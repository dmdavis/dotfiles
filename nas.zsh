#!/usr/bin/env zsh

# Define the actual values of these exports in files NOT checked into version
# control.
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

# Upload a movie or TV show to a subfolder of the `/volume1/video` NAS share.
upvid() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "USAGE: upvid path-to-file-or-folder nas-video-sub-folder"
        return 1
    fi

    echo Copying "$1" to "$NAS_IP:/volume1/video/$2"
    if rsync -azvhP -e "ssh -p $NAS_SSH_PORT" "$1" "$NAS_USER@$NAS_IP":/volume1/video/"$2"; then
        echo Moving "$1" to Trash
        trash "$1"
    else
        echo "Failed to copy $1 to $NAS_IP:/volume1/video/$2"
        return 1
    fi
}