#!/usr/bin/env bash

echo "Generating SSH key"
ssh-keygen -t rsa -b 4096 -C "$1"
cat "$HOME/.ssh/id_rsa.pub"

read -r -p "Copy the public key above to Github, then press [Enter] to continue..."
echo "Installing dotfiles"
git clone git@github.com:dmdavis/dotfiles.git ~/.files && ~/.files/install
echo "Edit your .bashrc to load appropriate profile."

# Dev tools

