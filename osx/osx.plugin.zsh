#!/usr/bin/env zsh
export HOMEBREW_EDITOR=/usr/local/bin/vim
export FONTCONFIG_PATH=/opt/X11/lib/X11/fontconfig

alias updatedb='sudo time /usr/libexec/locate.updatedb'
alias ep="mate $DOTFILES"
alias mft='find . -name Makefile | xargs trash'
alias dash="$DOTFILES/python/dash.py"
if [[ -f /Applications/Postgres.app/Contents/Versions/9.4/bin/psql ]]; then
    alias psql=/Applications/Postgres.app/Contents/Versions/9.4/bin/psql
fi
alias htop='sudo htop'
alias iftop='sudo iftop'
alias imgcat="$SCRIPTS/iterm2/imgcat"

# Qt 5.5.1
if [[ -d "$HOME/Tools/Qt5.5.1" ]]; then
    export PATH=$HOME/Tools/Qt5.5.1/5.5/clang_64/bin:$PATH
fi

# Growl
function growl {
    echo -e $'\e]9;'$1'\007'
}

# Check for Sparkle vulnerability
# http://www.macrumors.com/2016/02/09/sparkle-hijacking-vulnerability/
check-for-sparkle() {
    echo "Anything below $fg[red]1.13.1$fg[default] is potentially vulnerable"
    find /Applications/ -path '*Sparkle.framework*/Info.plist' -exec echo {} \; -exec grep -A1 CFBundleShortVersionString '{}' \; | grep -v CFBundleShortVersionString
}

test -e ${HOME}/.iterm2_shell_integration.bash && source ${HOME}/.iterm2_shell_integration.bash
