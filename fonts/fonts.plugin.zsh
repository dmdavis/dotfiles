#!/usr/bin/env bash

# Returns 0 if installed so function may be called with "if"
# e.g. if is-font-installed foo; then ...
is-font-installed() {
    fontname=$1
    fc-list | grep -i "$fontname" >/dev/null
}