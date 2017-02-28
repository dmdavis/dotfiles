#!/usr/bin/env zsh
alias todo='todo.sh -d ~/.files/todo/todo.cfg'
function t {
# Default (list)
    if [[ "$#" < 1 ]]; then
        todo
    # Any (l)ist command
    elif [ "$1" =~ '^l.+$' ]; then
        todo "$1"
    # All other commands are followd by list
    else
        todo "$@"
        todo ls
    fi
}
