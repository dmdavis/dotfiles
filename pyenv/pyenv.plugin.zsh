eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv virtualenvwrapper
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
alias workon="pyenv global $1"
alias wo="workon"
alias lsv="pyenv versions"
alias rmv="pyenv uninstall"