# `.zshrc' is sourced in interactive shells. It should contain commands to set up
# aliases, functions, options, key bindings, etc.

# Homebrew
eval $(/opt/homebrew/bin/brew shellenv)

# This `prev` function is from `pet : CLI Snippet Manager`
# https://github.com/knqyf263/pet#zsh-prev-function
function prev() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new `printf %q "$PREV"`"
}

# Aliases
alias ll='ls -la'

# Set up command line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
