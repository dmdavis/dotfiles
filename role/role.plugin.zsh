#!/usr/bin/env zsh

if [[ -f "$HOME/.role" ]]; then
    role=$(<"$HOME/.role")
    source "$DOTFILES/role/$role"
fi