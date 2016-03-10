#!/usr/bin/env bash
# Aliases
alias yolk="python $DOTFILES/python/yolk2.py"
alias pf='pip freeze'
alias pi='pip install'
alias pind='pip install --no-deps'
alias piu='pip install -U'
alias pid='pip install -e .'
alias pir='pip install -r'
alias pidnd='pip install --no-deps -e .'
alias pm='python manage.py'
alias fsp='python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"'
alias rmpyc='rmr *.pyc'
alias which-sitepackages='python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"'

# Functions
mkve() {
    if [[ $# < 1 ]]; then
        echo "USAGE:   mkve [version>] <name>"
        echo "EXAMPLE: mkve 2.7.10 blogadmin"
        echo "         mkve myvenv  # Defaults to current python version"
    else
        local pyv=`python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'`
        local name=$1
        if [[ $# > 1 ]]; then
            pyv=$1
            name=$2
        fi
        pyenv virtualenv $pyv $name
    fi
}

# Save active virtualenv's
function venvreqs {
    venvname=`echo $VIRTUAL_ENV | awk -F/ '{print $NF}'`
    if [[ -n $venvname ]]; then
        filename=reqs_$venvname.txt
        if [[ -f $filename ]]; then
            rm -f $filename
        fi
        pip freeze | sed s/==/\>=/ | sed "s/^-e/# -e/" > $filename
    fi
}