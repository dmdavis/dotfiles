#!/usr/bin/env zsh

if [[ -f "$HOME/.host-specific" ]]; then
    host_specific=$(<"$HOME/.host-specific")
    source "$DOTFILES/host-specific/$host_specific"
fi