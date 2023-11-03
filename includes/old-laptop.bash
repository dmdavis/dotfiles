#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing old-laptop.bash"
    echo "PATH = $PATH"
fi

# Some helpers for copying crap from old laptop to new.
export OLD_MACBOOK=''
export NEW_MACBOOK=''
alias oldmb='ssh $DEV_USER@$OLD_MACBOOK'
alias newmb='ssh $DEV_USER@$NEW_MACBOOK'
function oldtonew() {
    # oldtonew ~/go/src/ssd-git.juniper.net/contrail
    mkdir -p "$1"
    rsync -azvhP "${DEV_USER}@${OLD_MACBOOK}:${1}/" "$1"
}
function newtoold() {
    ssh "${DEV_USER}@${NEW_MACBOOK}" mkdir -p "$1"
    rsync -azvhP "$1/" "${DEV_USER}@${OLD_MACBOOK}:${1}"
}