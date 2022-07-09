#!/usr/bin/env bash
# see: https://gist.github.com/dorentus/4689543
#      http://blog.tomtung.com/2009/11/cowsay-fortune
#      http://www.commandlinefu.com/commands/view/3584/remove-color-codes-special-characters-with-sed
#      https://github.com/busyloop/lolcat
#      https://github.com/dorentus/mruby-lolcat-bin
#
#      requires `neofetch`, `fortune`, `cowsay`, and ruby gem `lolcat` or its
#      mruby version equivalent

function motd-fabulous() {
    printf "\n"
    local cmd_lolcat cowdo cowdos msg mode modes motd random_cow speaker
    # Message of the day
    motd=$(</etc/motd)
    # Randomly pick a quote
    msg=$(fortune)
    msg="$motd\n\n$msg"
    # Randomly pick a mode of the cow
    modes=("" -b -d -g -p -s -t -w -y ); mode=${modes[$((RANDOM % 9))]}
    # cowsay or cowthink?
    cowdos=(cowsay cowthink); cowdo=${cowdos[$((RANDOM % 2))]}
    # Randomly pick a cow picture file if the caller doesn't specify one (see `cowsay -l`)
    random_cow=$(cowsay -l | sed '1d;s/ /\n/g'| sort -R | head -1)
    speaker="${1:-$random_cow}"
    # lolcat
    cmd_lolcat="$(command -v lolcat_m)" || cmd_lolcat="$(command -v lolcat)"
    # That's it ^^
    echo -e "$msg" | $cowdo -n -f "$speaker" "$mode" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | $cmd_lolcat -f
    printf "\n"
    neofetch
}

alias llc='ll | lolcat'
