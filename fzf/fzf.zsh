if (( $+commands[fzf] )); then
    if [[ -d "$HOME/.linuxbrew" ]]; then
        local OPT_PATH="$HOME/.linuxbrew/opt"
    else
        local OPT_PATH='/usr/local/opt'
    fi

    # Setup fzf
    # ---------
    if [[ ! "$PATH" == *$OPT_PATH/fzf/bin* ]]; then
      export PATH="$PATH:$OPT_PATH/fzf/bin"
    fi

    # Man path
    # --------
    if [[ ! "$MANPATH" == *$OPT_PATH/fzf/man* && -d "$OPT_PATH/fzf/man" ]]; then
      export MANPATH="$MANPATH:$OPT_PATH/fzf/man"
    fi

    # Auto-completion
    # ---------------
    [[ $- == *i* ]] && source "$OPT_PATH/fzf/shell/completion.zsh" 2> /dev/null

    # Key bindings
    # ------------
    source "$OPT_PATH/fzf/shell/key-bindings.zsh"
fi
