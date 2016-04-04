#!/usr/bin/env zsh

if (( $+commands[VBoxManage] )); then
    alias vb='VBoxManage'
    alias vbn='VBoxManage natnetwork'
    alias vbns='VBoxManage natnetwork start'
    alias vbnx='VBoxManage natnetwork stop'
    alias vbnr='VBoxManage natnetwork remove'
    alias vbnm='VBoxManage natnetwork modify'
    alias vbnl='VBoxManage list natnetworks'
fi

