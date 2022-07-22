#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing ubuntu.bash"
    echo "PATH = $PATH"
fi

# I'm Batcat (under Ubuntu)
# https://github.com/sharkdp/bat
alias cat='batcat --theme=TwoDark'
