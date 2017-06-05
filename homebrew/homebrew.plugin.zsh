#!/usr/bin/env zsh

export HOMEBREW_CELLAR="`brew --prefix`/Cellar"
alias cellar="cd $HOMEBREW_CELLAR"
alias caskI='brew cask install --force'
alias caskU="brew cask install --force $(brew cask list)"

# Force upgrade all Jetbrains IDEs
function caskJ {
    caskI appcode
    caskI clion
    caskI datagrip
    caskI intellij-idea
    caskI phpstorm
    caskI pycharm
    caskI rubymine
    caskI webstorm
}

# Custom brew aliases
alias bubo='brew update && brew outdated'
alias bubc='brew upgrade && brew cleanup'

function brewfile {
    brew bundle --file="$BREWFILE_PATH"
}

# tccutil uses homebrew's Python 2.7, not pyenv's
function tccutil {
    sudo /usr/local/bin/python /usr/local/bin/tccutil "$@"
}
