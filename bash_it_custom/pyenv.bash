if [[ $(command -v pyenv) != "" ]]
then
    # Virtual environment creation
    function venv {
      LAST_VENV="${PWD##*/}-$PYTHON_VERSION"
      msg "Creating local virtual environment $LAST_VENV..."
      pyenv virtualenv "${PYTHON_VERSION}" "${LAST_VENV}" || return
      pyenv local "${LAST_VENV}" || return
      pip install --upgrade pip || return
      pip install --upgrade setuptools || return
      msg "Successfully created $LAST_VENV"
    }
    # Conda/pyenv virtualenv
    function cvenv {
      pyenv local "$CONDA_VERSION"
      LAST_VENV="${PWD##*/}-$CONDA_VERSION"
      pyenv virtualenv --clone "${CONDA_VERSION}" "${CONDA_VERSION}" "${LAST_VENV}"
      pyenv local "${LAST_VENV}"
      msg "Successfully created $LAST_VENV"
    }
    function venv-drop {
      local vname="${PWD##*/}-$PYTHON_VERSION"
      msg "Switching local pyenv back to system"
      pyenv local system
      pyenv uninstall -f "${vname}" || return
      msg "Removed $vname"
    }
    alias vls="pyenv versions --skip-aliases"
    function venv-rebuild {
        venv-drop
        venv
    }
fi

