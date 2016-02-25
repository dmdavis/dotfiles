# .files @ dmdavis
This repository contains my personal collection of shell initialization and configuration scripts.

After years of using [Dropbox][] to manage and synchronize configuration files and shell scripts, I've moved to a [git][]-backed model leveraging tools such as [dotbot][] and [zgen][] for installation and plugin management.

The goal is the ability to completely configuration my regular shell environment and tools on any of the Unix-variants I typically work on by cloning the repository and running an installation script.

## Features

* [dotbot][] for *one-click* dotfile installation and update
* [Vim][] Configuration
  * [Janus: VIM Distribution][janus] for base Vim setup
  * [a.vim - Alternate Files Quickly][a.vim] for switching between corresponding files (e.g. *.c ⇔ @.h)
* [Z shell][zsh] Configuration
  * [Prezto][prezto] Framework
  * [powerlevel9k][] Prompt Theme

## Installation

To install, execute the following commands in a shell:

```bash
git clone git@github.com:dmdavis/dotfiles.git ~/.files && ~/.files/install
```

The [installation script](install) will update repository [submodules](./.gitmodules), create symlinks to dotfiles within the repo, and install [Janus VIM][janus] if needed.

Cheers! :beer:

## Updating

To update repository [submodules](.gitmodules) and [Janus VIM][janus], execute the [install](./install) script again.

```bash
~/.files/install
```

## Conventions

I'm trying to follow a few basic coding conventions with the files in this repository.

* Installation files executed by [dotbot][] should be portable and target /bin/sh so that install will work regardless of shell
* Z shell plugin files have a *.plug.zsh extension

### Thanks

This project would not be possible without the clever work of the contributors to the many [open-source software](w-oss) tools upon which it is based.

> "If I have seen further, it is by standing on the shoulders of giants."

- [Sir Isaac Newton][w-isaac] *and [others][w-giants]*

### Fork Moi?

I tried the fork and customize model with [prezto][] for a while, but I've since come around to the idea that dotfiles are [personal][] settings. What may work great for me may not be optimum for you. My goal with this repo is to optimize my personal shell and editor configs, not create a generic framework. There are plenty of those out there, and this repo uses some of them as submodules.

Still, I've gotten this far through the generous sharing of other clever dotfile enthusiasts, so all this is [open source](LICENSE). If you see anything useful, please copy it with my compliments.

[a.vim]:        http://www.vim.org/scripts/script.php?script_id=31
[dotbot]:       https://github.com/anishathalye/dotbot
[Dropbox]:      https://www.dropbox.com
[git]:          https://git-scm.com
[janus]:        https://github.com/carlhuda/janus
[personal]:     http://www.anishathalye.com/2014/08/03/managing-your-dotfiles/
[powerlevel9k]: https://github.com/bhilburn/powerlevel9k
[prezto]:       https://github.com/sorin-ionescu/prezto
[Vim]:          http://www.vim.org
[w-giants]:     https://en.wikipedia.org/wiki/Standing_on_the_shoulders_of_giants
[w-isaac]:      https://en.wikipedia.org/wiki/Isaac_Newton
[w-oss]:        https://en.wikipedia.org/wiki/Open-source_software
[zgen]:         https://github.com/tarjoilija/zgen
[zsh]:          http://zsh.sourceforge.net
