# Set window/tab title
function title {
  echo -ne "\e]1;$1\a"
}

# Switch to cyan, echo, then reset4
function msg {
  tput setaf 6; echo "$@"; tput sgr0
}