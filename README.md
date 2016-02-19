# .files @ dmdavis
This repository contains my personal collection of initialization and configuration scripts.

After years of using Dropbox to manage and synchronize configuration files and shell scripts, I've moved to a git-backed model leveraging tools such as [dotbot](https://github.com/anishathalye/dotbot) and [zplug](https://github.com/b4b4r07/zplug) for installation and plugin management.

The goal is to be able to completely configuration my regular shell environment and tools by cloning the repository and running an installation script.

### Fork Me?

I tried the fork and customize model with [prezto](https://github.com/sorin-ionescu/prezto) for a while, but I've since come around to the idea that dotfiles are [personal settings](http://www.anishathalye.com/2014/08/03/managing-your-dotfiles/). What may work great for me may not be optimum for you. My goal with this repo is to optimize my personal shell and editor configs, not create a generic framework. There are plenty of those out there, and this repo uses some of them as submodules.

Still, I've gotten this far through the generous sharing of other clever dotfile enthusiasts, so all this is [open source](LICENSE). If you see anything useful, please copy it with my compliments.

---

## Installation

To install, execute the following commands in a shell:

```bash
git clone git@github.com:dmdavis/dotfiles.git ~/.files
cd ~/.files
git submodule update --init --recursive
./install
```

Cheers! :beer: