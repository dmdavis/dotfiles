#!/usr/bin/env bash

# The following two public key recovery functions are from
# https://stackoverflow.com/questions/5244129/use-rsa-private-key-to-generate-public-key

# Prints a `-----BEGIN PUBLIC KEY-----` style public key
function public_key_from_private_openssl {
    openssl rsa -in "$1" -pubout
}

# Prints out `id_rsa.pub` style public key sans comment (i.e. no email or whatever)
function public_key_from_private_ssh_keygen {
    ssh-keygen -y -f "$1"
}

# Prints out SSH key fingerprint
# From https://stackoverflow.com/questions/9607295/calculate-rsa-key-fingerprint
function ssh_key_fingerprint {
    ssh-keygen -E md5 -lf "$1"
}
