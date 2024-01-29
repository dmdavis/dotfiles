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
    echo
    echo "$upgradeable"
    echo
    echo "To upgrade:"
    echo "  sudo update & sudo apt upgrade -y"
    echo "To upgrade 'held back' packages:"
    echo "  sudo apt-get --with-new-pkgs upgrade -y <packages>"
fi

# No Bash-It plugin yet for cargo and go environments.

# shellcheck source=../../.cargo/env
[ -f "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"

# shellcheck source=../../.go-env.bash
[ -f "${HOME}/.go-env.bash" ] && source "${HOME}/.go-env.bash"
