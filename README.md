# .files @ dmdavis
This repository contains my personal collection of shell initialization and configuration scripts.

After years of using [Dropbox][] to manage and synchronize configuration files and shell scripts, I've moved to a [git][]-backed model based on [Bash-It][]. Previously, I was using [zsh], but switched back to bash for compatibility and complexity issues.

The goal is the ability to completely configuration my regular shell environment and tools on any of the Unix-variants I typically work on by cloning the repository and running an installation script.

## Installation

To install, execute the following commands in a shell:

```bash
git clone git@github.com:dmdavis/dotfiles.git ~/.files && ~/.files/install
```

Cheers! :beer:

[Dropbox]:        https://www.dropbox.com
[git]:            https://git-scm.com
[Bash-It]:        https://github.com/Bash-it/bash-it
[zsh]:            http://zsh.sourceforge.net
