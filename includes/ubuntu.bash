#!/usr/bin/env bash
if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing ubuntu.bash"
    echo "PATH = $PATH"
fi

# I'm Batcat (under Ubuntu)
# https://github.com/sharkdp/bat
alias bat='batcat --theme=TwoDark'

# VSCode requires access to TMPDIR on host
# Can no longer use this because of idiots hard-coding temp directory paths in
# tests and a shit-show review process.
#export TMPDIR="${HOME}/tmp"
