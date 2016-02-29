#!/usr/bin/env zsh

if [[ -f "$HOME/.host-specific" ]]; then
    host_specific=$(<"$HOME/.host-specific")
    source "$DOTFILES/zsh/host-specific/$host_specific"
fi