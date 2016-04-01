#!/usr/bin/env zsh
if is-font-installed 'SourceCodePro+Powerline+Awesome Regular'; then
    POWERLEVEL9K_MODE='awesome-patched'
fi
POWERLEVEL9K_NVM_FOREGROUND='black'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vi_mode vcs)

# Power Level 9000 customization
function plc {
    # TODO: Add plc zsh completion
    case "$1" in
        ruby|rails)
            echo "$FG[yellow]\uE802$FG[none]  Configuring $FG[blue]\uE0B2$BG[blue]$FG[black]Power Level $FG[bold]9000$BG[none]$FG[blue]\uE0B0$FG[none] for $FG[red]\uE847 Ruby$FG[none] development"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vi_mode rbenv vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
            ;;
        node|nvm)
            echo "$FG[yellow]\uE802$FG[none]  Configuring $FG[blue]\uE0B2$BG[blue]$FG[black]Power Level $FG[bold]9000$BG[none]$FG[blue]\uE0B0$FG[none] for $FG[green]\u2B22 Node$FG[none] development"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vi_mode nvm vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
            ;;
        python|pyenv)
            echo "$FG[yellow]\uE802$FG[none]  Configuring $FG[blue]\uE0B2$BG[blue]$FG[black]Power Level $FG[bold]9000$BG[none]$FG[blue]\uE0B0$FG[none] for $FG[green]🐍 Python$FG[none] development"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vi_mode virtualenv vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
            ;;
        *)
            echo "$FG[yellow]\uE802$FG[none]  Configuring $FG[blue]\uE0B2$BG[blue]$FG[black]Power Level $FG[bold]9000$BG[none]$FG[blue]\uE0B0$FG[none] with default settings"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vi_mode vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
    esac
}
