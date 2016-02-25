#!/bin/sh
# requires rake and curl
if [ -f $HOME/.vim/Rakefile ]; then
    # Already installed. Update.
    cd ~/.vim
    rake
    cd
else
    curl -L https://bit.ly/janus-bootstrap | $SHELL
fi
