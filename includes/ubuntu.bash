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

# No Bash-It plugin yet for cargo.
# shellcheck source=../../.cargo/env
[ -f "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"

# The Bash-It plugin doesn't export GO_ROOT.
# shellcheck source=../../.go-env.bash
[ -f "${HOME}/.go-env.bash" ] && source "${HOME}/.go-env.bash"

# The Bash-It fzf plugin doesn't appear to work. When installing fzf, you can
# enable the key-bindings, but not auto-completion. Doing so results in a bash
# error when sourcing ~/.fzf.bash:
#
# -bash: eval: line 701: unexpected EOF while looking for matching `''
#
# TODO: Fix EOF error in source ~/.fzf/shell/completion.bash

# shellcheck source=../../.fzf.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
