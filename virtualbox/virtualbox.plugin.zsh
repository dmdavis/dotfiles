#!/usr/bin/env zsh

if (( $+commands[VBoxManage] )); then
    alias vb='VBoxManage'
    alias vbnn='VBoxManage natnetwork'
fi

