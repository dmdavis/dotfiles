#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing ls-colors.bash"
    echo "PATH = $PATH"
fi

# curl https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/lscolors.sh -o ~/.ls-colors.sh

# Set up LS_COLORS if present
if [[ -r "$HOME/.ls-colors.sh" ]]; then
    # shellcheck source=$/.ls-colors.sh
    source "$HOME/.ls-colors.sh"
fi
