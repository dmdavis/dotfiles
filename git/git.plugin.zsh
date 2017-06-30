#!/usr/bin/env zsh

alias wip='git add .; git commit -m "wip"'
alias yolo='git push --force'
alias gsm="grep path .gitmodules | sed 's/.*= //'"
alias gfu='git fetch upstream'
alias gum='git config user.email'
alias gRv='git remote -v'
alias gro='git rebase --onto'

# --verbose with color remote branches
alias gbv='git branch -vv'
