#!/usr/bin/env zsh

POWERLEVEL9K_MODE='awesome-patched'
POWERLEVEL9K_NVM_FOREGROUND='black'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)

# Power Level 9000 customization
function plc {
    case "$1" in
        ruby)
            echo "$FG[yellow]\uE802$FG[none]  Configuring $FG[blue]\uE0B2$BG[blue]$FG[black]Power Level $FG[bold]9000$BG[none]$FG[blue]\uE0B0$FG[none] for $FG[red]\uE847 Ruby$FG[none] development"
            echo "Configuring $FG[blue]powelevel9k$FG[none] for $FG[red]ruby$FG[none] development"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
            ;;
        node)
            echo "$FG[yellow]\uE802$FG[none]  Configuring $FG[blue]\uE0B2$BG[blue]$FG[black]Power Level $FG[bold]9000$BG[none]$FG[blue]\uE0B0$FG[none] for $FG[green]\u2B22 Node$FG[none] development"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir nvm vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
            ;;
        *)
            echo "$FG[yellow]\uE802$FG[none]  Configuring $FG[blue]\uE0B2$BG[blue]$FG[black]Power Level $FG[bold]9000$BG[none]$FG[blue]\uE0B0$FG[none] with default settings"
            echo "Configuring $FG[blue]powelevel9k$FG[none] with default settings"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
    esac
}