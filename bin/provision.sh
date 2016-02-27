#!/bin/sh
if [ -f /etc/lsb-release ]; then
    OS=$(lsb_release -s -d)
elif [ -f /etc/debian_version ]; then
    OS="Debian $(cat /etc/debian_version)"
elif [ -f /etc/redhat-release ]; then
    OS=`cat /etc/redhat-release`
else
    OS="$(uname -s) $(uname -r)"
fi
if [[ "$OS" == Darwin* ]]; then
    echo "Installing/upgrading Homebrew and Cask packages"
    command -v brew >/dev/null 2>&1 || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap homebrew/bundle 2>/dev/null;
    brew install bundle 2>/dev/null;
    brew bundle ../homebrew/brewfile
elif [[ "$OS" == Fedora* ]]; then
    echo "TODO: Installing/upgrading yum packages"
else # Debian, Ubuntu, Linux Mint, and other apt-based distros
    echo "TODO: Installing/upgrading apt packages"
fi
