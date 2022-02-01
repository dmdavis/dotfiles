# Path to the bash it configuration
export BASH_IT="$HOME/.bash_it"
export BASH_IT_CUSTOM="$HOME/.files/bash_it_custom/"

# Lock and Load a custom theme file.
# Leave empty to disable theming.
# location /.bash_it/themes/
export BASH_IT_THEME="${BASH_IT_THEME:-zork}"

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
#export SHORT_HOSTNAME=$(hostname -s)

# Set Xterm/screen/Tmux title with only a short username.
# Uncomment this (or set SHORT_USER to something else),
# Will otherwise fall back on $USER.
#export SHORT_USER=${USER:0:8}

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
#export SHORT_TERM_LINE=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload.
# export BASH_IT_RELOAD_LEGACY=1

# Ignore duplicate history entries
export HISTCONTROL=ignoreboth:erasedups

# XDG config home (used by stuff like nvim
export XDG_CONFIG_HOME="$HOME/.config"

# bash-it themes use UTF-8
export LC_ALL=en_US.UTF-8

# Load Bash It
# shellcheck source=../../.bash_it/bash_it.sh
source "$BASH_IT/bash_it.sh"

alias alg='alias | grep'

# Disable pipenv warnings about defaulting to the active venv
export PIPENV_VERBOSITY=-1

# Change current $PYTHON_VERSION
function pyver() {
    export PYTHON_VERSION="$1"
}

# List enabled Bash It aliases, completions, and plugins
function bashen() {
    msg "Bash It - Enabled Aliases"
    bashit show aliases | grep '\[x\]'
    msg "Bash It - Enabled Completions"
    bashit show completions | grep '\[x\]'
    msg "Bash It - Enabled Plugins"
    bashit show plugins | grep '\[x\]'
}

# ls with octal file permissions
# Source: https://askubuntu.com/questions/152001/how-can-i-get-octal-file-permissions-from-command-line
lso() {
    # Suppress "use find instead of ls" shellcheck warning
    # shellcheck disable=SC2012
    ls -alG "$@" | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(" %0o ",k);print}';
}

# Common lso alias (overridden in downstream BASH files)
alias llo='lso'

# tar aliases
alias compress='tar -czvf'
# Remember to add `-C <destination>` if you want to uncompress to a different
# folder.
alias uncompress='tar -xzvf'
