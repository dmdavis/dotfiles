#!/usr/bin/env bash

if [[ "$DOTFILE_TRACE" -eq 1 ]]; then
    echo "* Sourcing kubectl.bash"
    echo "PATH = $PATH"
fi

# Other kubectl alias are defined in Bash-Its `kubectl` alias extension.
# Enable it via `bashit enable alias kubectl`.

alias kcds='kubectl describe service'
alias kcgrs='kubectl get replicasets'
alias kcgs='kubectl get services'
alias kcgsan='kubectl get services --all-namespaces'
alias kclp="kubectl label pods"
alias kcx='kubectl exec -it'
alias kcxsp="kubectl expose"

# k = kc = kubectl
alias k=kubectl
