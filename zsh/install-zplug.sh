#!/bin/sh
if [ ! -d $HOME/.zplug ]; then
    it clone https://github.com/b4b4r07/zplug $HOME/.zplug
else
    if [ command -v zplug ]; then
        zplug update
    fi
fi
