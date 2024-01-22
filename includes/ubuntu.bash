#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing ubuntu.bash"
    echo "PATH = $PATH"
fi

# I'm Batcat (under Ubuntu)
# https://github.com/sharkdp/bat
alias bat='batcat --theme=TwoDark'

lsb_release --description
lsb_release --release
lsb_release --codename

upgradeable=$(apt list --upgradeable 2>/dev/null)
if [ "$upgradeable" != 'Listing...' ]; then
    echo
    echo "Upgradeable apt packages:"
    echo "$upgradeable"
fi
