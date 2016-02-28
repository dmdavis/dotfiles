#!/usr/bin/env zsh

POWERLEVEL9K_MODE='awesome-patched'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)

# Power Level 9000 customization
function plc {
    case "$1" in
        ruby)
            echo "Configuring powelevel9k for ruby development"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
            ;;
        *)
            echo "Configuring powerlevel9k with default settings"
            POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
    esac
}