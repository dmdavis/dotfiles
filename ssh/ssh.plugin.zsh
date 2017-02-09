#!/usr/bin/env zsh

function ssh-to {
  bat $1;
	echo -e "\033]6;1;bg;red;brightness;209\a"
	echo -e "\033]6;1;bg;green;brightness;209\a"
	echo -e "\033]6;1;bg;blue;brightness;254\a"
	ssh ${@:2};
	bat ""
	echo -e "\033]6;1;bg;*;default\a"
}

function backtomymac {
    ssh-to my.mac dale@retina-pro.`echo show Setup:/Network/BackToMyMac | scutil | sed -n 's/.* : *\(.*\).$/\1/p'`
}

alias htpc='ssh-to htpc dale@htpc.local'
alias insom='ssh-to insom dale_insomnihack@ssh.phx.nearlyfreespeech.net'
alias barb='ssh-to barblog dale_barbdahlgren@ssh.phx.nearlyfreespeech.net'
alias shelly='ssh-to smommy dale_sophiasmommy@ssh.phx.nearlyfreespeech.net'
alias raspberrypi-2b='ssh-to pi pi@raspberrypi-2b.local'

