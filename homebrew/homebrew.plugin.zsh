#!/usr/bin/env zsh

export HOMEBREW_CELLAR="`brew --prefix`/Cellar"
alias cellar="cd $HOMEBREW_CELLAR"

# tccutil uses homebrew's Python 2.7, not pyenv's
function tccutil {
    sudo /usr/local/bin/python /usr/local/bin/tccutil "$@"
}