Templates README
================

This folder contains templates for configuration files for various tools like
`git` and `vim`.

## Gitconfig

Git configuration template with common settings and aliases cribbed from various
locations over the years.

## Stupid Git Tricks

If your standard `gitconfig` template is being used and [Git Extras](https://github.com/tj/git-extras)
are installed, the following aliases and shortcuts are available. See 
[Git Extras Commands](https://github.com/tj/git-extras/blob/master/Commands.md)
for more information on functionality provided by that library.

## Local Branch Wrangling

To understand which of the many old and abandoned branches are no longer needed,
you have a couple options:

* Use the `git recentb` alias for a colorized listing of local branches from most
  to least recent.
* Use the `git show-merged-branches` command to list local branches whose contents
  have been merged to the current branch. This may include branches you created,
  but never got around to working on, or stashed the changes when you switched
  to work on another branch. These branches can be deleted with the `gbx` alias
  (i.e. `git branch --delete`).
* Use the `git show-merged-branches` command to list local branches whose contents
  **have not** been merged to the current branch. You'll have to check these
  branches before deleting them with the `gbX` alias (i.e. `git branch --delete --force`).
