#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing ubuntu.bash"
    echo "PATH = $PATH"
fi

# I'm Batcat (under Ubuntu)
# https://github.com/sharkdp/bat
alias bat='batcat --theme=TwoDark'

# Bazelisk/Bazel
alias bz='bazelisk'

if [[ "$LSB_INFO" -eq 1 ]]; then
  lsb_release --description 2>/dev/null
  lsb_release --release 2>/dev/null
  lsb_release --codename 2>/dev/null
fi

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

# Is a package installed? i.e. aptlq build-essential. If no, returns nothing.
alias aptlq='apt -qq list'

# No Bash-It plugin yet for cargo and go environments.

# shellcheck source=../../.cargo/env
[ -f "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"

# shellcheck source=../../.go-env.bash
[ -f "${HOME}/.go-env.bash" ] && source "${HOME}/.go-env.bash"

# The Bash-It plugin doesn't always work?

# shellcheck source=../../.fzf.bash
#[ -f "${HOME}/.fzf.bash" ] && source "${HOME}/.fzf.bash"