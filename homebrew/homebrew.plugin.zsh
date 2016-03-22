#!/usr/bin/env zsh

export HOMEBREW_CELLAR="`brew --prefix`/Cellar"
alias cellar="cd $HOMEBREW_CELLAR"
alias caskI='brew cask install --force'

# Custom brew aliases
alias bubo='brew update && brew outdated'
alias bubc='brew upgrade --all && brew cleanup'

function brewfile {
    brew bundle --file="$BREWFILE_PATH"
}

# tccutil uses homebrew's Python 2.7, not pyenv's
function tccutil {
    sudo /usr/local/bin/python /usr/local/bin/tccutil "$@"
}