#!/usr/bin/env zsh

export HOMEBREW_CELLAR="`brew --prefix`/Cellar"
alias cellar="cd $HOMEBREW_CELLAR"

function brewfile {
    brew bundle --file="$DOTFILES/homebrew/brewfile"
}

# tccutil uses homebrew's Python 2.7, not pyenv's
function tccutil {
    sudo /usr/local/bin/python /usr/local/bin/tccutil "$@"
}