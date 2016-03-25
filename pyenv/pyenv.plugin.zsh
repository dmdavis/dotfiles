#!/usr/bin/env zsh

export PYENV_ROOT="${HOME}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    pyenv virtualenvwrapper
    export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
    alias workon="pyenv global $1"
    alias wo="workon"
    alias lsv="pyenv versions"
    alias rmv="pyenv uninstall"
fi
export PATH
