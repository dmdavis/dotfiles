#!/usr/bin/env bash

# Both powerline and awesome terminal require fontfconfig
command -v fc-cache >/dev/null 2>&1 || { echo >&2 "Font installation requires fc-cache from fontconfig. Aborting."; exit 0; }
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "$FG[yellow]Installing powerline fonts$FG[none]"
"$DIR/powerline-fonts/install.sh"

echo "$FG[yellow]Installing awesome-terminal-fonts$FG[none]"
"$DIR/awesome-terminal-fonts/install.sh"

# TODO: Install awesome terminal patched fonts