#!/usr/bin/env bash

if [[ $(command -v magick) != "" ]]; then
    heic2jpg() {
        # convert any HEIC image in a directory to jpg format
        magick mogrify -monitor -format jpg ./*.HEIC
        # To convert just one image:
        # magick convert example_image.HEIC example_image.jpg
    }
fi
