#!/usr/bin/env bash

# These aliases are based on ZPrezto git aliases
# https://github.com/sorin-ionescu/prezto/blob/master/modules/git/alias.zsh
# 1b441e7 on Apr 4, 2018

# bash_it git completion only loads on macOS because there's no reliable path
# to it on on the various distributions. Try a few known locations here.
if [[ "$(uname -s)" == 'Linux' ]] ; then
    # On Centos 7, git completion is lazy-loaded. __git_complete doesn't exist
    # until "git TAB" is called, so source the completion file if it is there.
    if [[ -r /usr/share/bash-completion/completions/git ]]; then
        source /usr/share/bash-completion/completions/git

    # On Synology DSM 6, bash completions aren't present in either
    # /usr/share/bash-completion/completions/git or /etc/bash_completion.d/git.
    # Use the following to download a local copy:
    #   curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash
    elif [ -f ~/.git-completion.bash ]; then
        # shellcheck source=$/.git-completion.bash
        source "$HOME/.git-completion.bash"
    fi
fi

git-branch-current() {
    git rev-parse --abbrev-ref HEAD
}

# Git
alias g='git'
__git_complete g __git_main

# Branch (b)
alias gb='git branch'
__git_complete gb _git_branch
alias gba='git branch --all --verbose'
__git_complete gba _git_branch
alias gbc='git checkout -b'
__git_complete gbc _git_checkout
alias gbd='git branch --delete'
__git_complete gbd _git_branch
alias gbD='git branch --delete --force'
__git_complete gbD _git_branch
alias gbl='git branch --verbose'
__git_complete gbl _git_branch
alias gbL='git branch --all --verbose'
__git_complete gbL _git_branch
alias gbm='git branch --move'
__git_complete gbm _git_branch
alias gbM='git branch --move --force'
__git_complete gbM _git_branch
alias gbr='git branch --move'
__git_complete gbr _git_branch
alias gbR='git branch --move --force'
__git_complete gbR _git_branch
alias gbs='git show-branch'
__git_complete gbs _git_show_branch
alias gbS='git show-branch --all'
__git_complete gbS _git_show_branch
alias gbu='git branch --set-upstream-to=origin/"$(git rev-parse --abbrev-ref HEAD)"'
alias gbv='git branch --verbose'
__git_complete gbv _git_branch
alias gbV='git branch --verbose --verbose'
__git_complete gbV _git_branch
alias gbx='git branch --delete'
__git_complete gbx _git_branch
alias gbX='git branch --delete --force'
__git_complete gbX _git_branch

# Commit (c)
alias gc='git commit --verbose'
__git_complete gc _git_commit
alias gca='git commit --verbose --all'
__git_complete gca _git_commit
alias gcm='git commit --message'
__git_complete gcm _git_commit
alias gcS='git commit -S --verbose'
__git_complete gcS _git_commit
alias gcSa='git commit -S --verbose --all'
__git_complete gcSa _git_commit
alias gcSm='git commit -S --message'
__git_complete gcSm _git_commit
alias gcam='git commit --all --message'
__git_complete gcam _git_commit
alias gco='git checkout'
__git_complete gco _git_checkout
alias gcO='git checkout --patch'
__git_complete gcO _git_checkout
alias gcf='git commit --amend --reuse-message HEAD'
__git_complete gcF _git_commit
alias gcSf='git commit -S --amend --reuse-message HEAD'
__git_complete gcSf _git_commit
alias gcF='git commit --verbose --amend'
__git_complete gcF _git_commit
alias gcSF='git commit -S --verbose --amend'
__git_complete gcSF _git_commit
alias gcp='git cherry-pick --ff'
__git_complete gcp _git_cherry_pick
alias gcP='git cherry-pick --no-commit'
__git_complete gcP _git_cherry_pick
alias gcr='git revert'
__git_complete gcr _git_revert
alias gcR='git reset "HEAD^"'
__git_complete gcR _git_reset
alias gcs='git show'
__git_complete gcs _git_show
alias gcl='git-commit-lost'
alias gcy='git cherry -v --abbrev'
alias gcY='git cherry -v'

# Conflict (C)
alias gCl='git --no-pager diff --name-only --diff-filter=U'
__git_complete gCl _git_diff
alias gCa='git add $(gCl)'
__git_complete gCa _git_add
alias gCe='git mergetool $(gCl)'
__git_complete gCe _git_mergetool
alias gCo='git checkout --ours --'
alias gCO='gCo $(gCl)'
alias gCt='git checkout --theirs --'
alias gCT='gCt $(gCl)'

# Data (d)
alias gd='git ls-files'
alias gdc='git ls-files --cached'
alias gdx='git ls-files --deleted'
alias gdm='git ls-files --modified'
alias gdu='git ls-files --other --exclude-standard'
alias gdk='git ls-files --killed'
alias gdi='git status --porcelain --short --ignored | sed -n "s/^!! //p"'

# Fetch (f)
alias gf='git fetch'
__git_complete gf _git_fetch
alias gfa='git fetch --all'
alias gfc='git clone'
__git_complete gfc _git_clone
alias gfcr='git clone --recurse-submodules'
__git_complete gfcr _git_clone
alias gfm='git pull'
__git_complete gfm _git_pull
alias gfr='git pull --rebase'
__git_complete gfr _git_pull

# Flow (F)
alias gFi='git flow init'
alias gFf='git flow feature'
alias gFb='git flow bugfix'
alias gFl='git flow release'
alias gFh='git flow hotfix'
alias gFs='git flow support'

alias gFfl='git flow feature list'
alias gFfs='git flow feature start'
alias gFff='git flow feature finish'
alias gFfp='git flow feature publish'
alias gFft='git flow feature track'
alias gFfd='git flow feature diff'
alias gFfr='git flow feature rebase'
alias gFfc='git flow feature checkout'
alias gFfm='git flow feature pull'
alias gFfx='git flow feature delete'

alias gFbl='git flow bugfix list'
alias gFbs='git flow bugfix start'
alias gFbf='git flow bugfix finish'
alias gFbp='git flow bugfix publish'
alias gFbt='git flow bugfix track'
alias gFbd='git flow bugfix diff'
alias gFbr='git flow bugfix rebase'
alias gFbc='git flow bugfix checkout'
alias gFbm='git flow bugfix pull'
alias gFbx='git flow bugfix delete'

alias gFll='git flow release list'
alias gFls='git flow release start'
alias gFlf='git flow release finish'
alias gFlp='git flow release publish'
alias gFlt='git flow release track'
alias gFld='git flow release diff'
alias gFlr='git flow release rebase'
alias gFlc='git flow release checkout'
alias gFlm='git flow release pull'
alias gFlx='git flow release delete'

alias gFhl='git flow hotfix list'
alias gFhs='git flow hotfix start'
alias gFhf='git flow hotfix finish'
alias gFhp='git flow hotfix publish'
alias gFht='git flow hotfix track'
alias gFhd='git flow hotfix diff'
alias gFhr='git flow hotfix rebase'
alias gFhc='git flow hotfix checkout'
alias gFhm='git flow hotfix pull'
alias gFhx='git flow hotfix delete'

alias gFsl='git flow support list'
alias gFss='git flow support start'
alias gFsf='git flow support finish'
alias gFsp='git flow support publish'
alias gFst='git flow support track'
alias gFsd='git flow support diff'
alias gFsr='git flow support rebase'
alias gFsc='git flow support checkout'
alias gFsm='git flow support pull'
alias gFsx='git flow support delete'

# Grep (g)
alias gg='git grep'
__git_complete gg _git_grep
alias ggi='git grep --ignore-case'
__git_complete ggi _git_grep
alias ggl='git grep --files-with-matches'
__git_complete ggl _git_grep
alias ggL='git grep --files-without-matches'
__git_complete ggl _git_grep
alias ggv='git grep --invert-match'
__git_complete ggv _git_grep
alias ggw='git grep --word-regexp'
__git_complete ggw _git_grep

# Index (i)
alias gia='git add'
__git_complete gia _git_add
alias giA='git add --patch'
__git_complete giA _git_add
alias giu='git add --update'
__git_complete giu _git_add
alias gid='git diff --no-ext-diff --cached'
alias giD='git diff --no-ext-diff --cached --word-diff'
alias gii='git update-index --assume-unchanged'
alias giI='git update-index --no-assume-unchanged'
alias gir='git reset'
__git_complete gir _git_reset
alias giR='git reset --patch'
__git_complete giR _git_reset
alias gix='git rm -r --cached'
__git_complete gix _git_rm
alias giX='git rm -rf --cached'
__git_complete giX _git_rm

# Log (l)
alias gl='git log --topo-order --pretty=format:"${_git_log_medium_format}"'
alias gls='git log --topo-order --stat --pretty=format:"${_git_log_medium_format}"'
alias gld='git log --topo-order --stat --patch --full-diff --pretty=format:"${_git_log_medium_format}"'
alias glo='git log --topo-order --pretty=format:"${_git_log_oneline_format}"'
alias glg='git log --topo-order --all --graph --pretty=format:"${_git_log_oneline_format}"'
alias glb='git log --topo-order --pretty=format:"${_git_log_brief_format}"'
alias glc='git shortlog --summary --numbered'

# Merge (m)
alias gm='git merge'
__git_complete gm _git_merge
alias gmC='git merge --no-commit'
alias gmF='git merge --no-ff'
alias gma='git merge --abort'
alias gmt='git mergetool'

# Push (p)
alias gp='git push'
__git_complete gp _git_push
alias gpf='git push --force-with-lease'
alias gpF='git push --force'
alias gpa='git push --all'
alias gpA='git push --all && git push --tags'
alias gpt='git push --tags'
alias gpc='git push --set-upstream origin "$(git-branch-current 2> /dev/null)"'
alias gpp='git pull origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)"'

# Rebase (r)
alias gr='git rebase'
__git_complete gr _git_rebase
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase --interactive'
alias grs='git rebase --skip'

# Remote (R)
alias gR='git remote'
__git_complete gR _git_remote
alias gra='git rebase --abort'
alias gRl='git remote --verbose'
alias gRa='git remote add'
__git_complete gRa _git_remote
alias gRx='git remote rm'
__git_complete gRx _git_remote
alias gRm='git remote rename'
alias gRu='git remote update'
alias gRp='git remote prune'
alias gRs='git remote show'
alias gRb='git-hub-browse'

# Stash (s)
alias gs='git stash'
__git_complete gs _git_stash
alias gsa='git stash apply'
alias gsx='git stash drop'
alias gsX='git-stash-clear-interactive'
alias gsl='git stash list'
alias gsL='git-stash-dropped'
alias gsd='git stash show --patch --stat'
alias gsp='git stash pop'
alias gsr='git-stash-recover'
# save has been deprecated, use push instead
alias gss='git stash push --include-untracked'
alias gsS='git stash push --patch --no-keep-index'
alias gsw='git stash push --include-untracked --keep-index'

# Submodule (S)
alias gS='git submodule'
alias gSa='git submodule add'
alias gSf='git submodule foreach'
alias gSi='git submodule init'
alias gSI='git submodule update --init --recursive'
alias gSl='git submodule status'
alias gSm='git-submodule-move'
alias gSs='git submodule sync'
alias gSu='git submodule foreach git pull origin master'
alias gSx='git-submodule-remove'

# Tag (t)
alias gt='git tag'
alias gtl='git tag -l'

# Working Copy (w)
alias gws='git status --ignore-submodules=${_git_status_ignore_submodules} --short'
alias gwS='git status --ignore-submodules=${_git_status_ignore_submodules}'
alias gwd='git diff --no-ext-diff'
alias gwD='git diff --no-ext-diff --word-diff'
alias gwr='git reset --soft'
alias gwR='git reset --hard'
alias gwc='git clean -n'
alias gwC='git clean -f'
alias gwx='git rm -r'
alias gwX='git rm -rf'

# My crap
alias wip='git add .; git commit -m "wip"'
alias yolo='git push --force'
alias greset='git reset --hard origin/"$(git rev-parse --abbrev-ref HEAD)"'
