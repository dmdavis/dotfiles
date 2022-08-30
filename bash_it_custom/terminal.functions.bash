#!/usr/bin/env bash

# Set window/tab title
function title() {
    echo -ne "\e]1;$1\a"
}

export MSG_COLOR="$echo_cyan"

function msg() {
    echo -e "${MSG_COLOR}$*${echo_normal}"
}
