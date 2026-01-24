# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# JetBrains IDEs run zsh with this set to read env vars.
# Keep this path FAST and SILENT (no output, no downloads, no prompts).
if [[ -n "${INTELLIJ_ENVIRONMENT_READER:-}" ]]; then
  # Only laod things that affect PATH/env:
  source "$HOME/.zshenv"
  # Things you might need in an IDE shell:
  eval "$(mise activate zsh)"
  return
fi

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older commands from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separators from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

# Load env vars from ~/.zshenv
source "$HOME/.zshenv"
# Ensure mise is activated for ZSH
eval "$(mise activate zsh)"

if [[ "$HOSTNAME" == "Dales-MacBook-Pro.local" ]]; then
  source "$DOTFILES/nas.zsh"
fi

# tmux helper
t() {
  tmux -CC attach -t "$1" || tmux -CC new -A -s "$1"
}

# Custom Aliases
alias alg='alias | grep'
alias ff='fastfetch --logo /Users/dale/SynologyDrive/Pictures/Avatars/rick_sanchez-4295.png.jpg --logo-type iterm --logo-width 60 --logo-height 29 --logo-padding-right 1'
alias lo='l --permission octal'
alias llo='ll --permission octal'
alias lc='l | lolcat'
alias llc='ll | lolcat'



# Terragrunt
alias tg=terragrunt

# Autojump
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# Kubebuilder aliases and completions
if (( ${+commands[kubebuilder]} )); then
  alias kb='kubebuilder'
  . <(kubebuilder completion zsh)
fi

# Kind completions
if (( ${+commands[kind]} )); then
  . <(kind completion zsh)
fi

# Task completions
if (( ${+commands[task]} )); then
  eval "$(task --completion zsh)"
fi

# LS_COLORS
source "$HOME/Repos/LS_COLORS/lscolors.sh"

# Host-specific overrides I don't want to check into version control.
if [[ -f "$DOTFILES/overrides.zsh" ]]; then
  source "$DOTFILES/overrides.zsh"
fi
