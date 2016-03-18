#!/usr/bin/env zsh

export HOMEBREW_CELLAR="`brew --prefix`/Cellar"
alias cellar="cd $HOMEBREW_CELLAR"
alias caskI='brew cask install --force'

# Override prezto homebrew aliases
alias brewu='brew update && brew outdated'
alias brewU='brew update && brew upgrade --all && brew cleanup'
alias brewv='brew upgrade --all && brew cleanup'

function brewfile {
    brew bundle --file="$BREWFILE_PATH"
}

# tccutil uses homebrew's Python 2.7, not pyenv's
function tccutil {
    sudo /usr/local/bin/python /usr/local/bin/tccutil "$@"
}