# git
alias wip='git add .; git commit -m "wip"'
alias yolo='git push --force'
alias gsm="grep path .gitmodules | sed 's/.*= //'"
alias githubgmail='git config user.email "dmdavis.net@gmail.com"'
# TODO: gl "git log" pretty alias is hosed. investigate. Want that 5 line default gl, gll, etc. thing back.
source "$DOTFILES/git/prezto-git-aliases"
# TODO: The above is hacky. Get prezto working with zplug and get these from the source.
alias gfu='git fetch upstream'
