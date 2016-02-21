#!/bin/sh
# requires rake and curl
if [ -d $HOME/.vim/janus ]; then
    # Already installed. Update.
    pushd .
    cd ~/.vim
    rake
    popd
else
    curl -L https://bit.ly/janus-bootstrap | $SHELL
fi