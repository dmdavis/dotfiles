# .files @ dmdavis

This repository contains my personal collection of initialization and
configuration scripts. It was originally inspired by [Jeff Geerling's dotfiles][]
repo. For my old Bash-based configuration using [Bash-It][], see the `bash-it`
branch. I'm currently using [zimfw][] for my Z-shell configuration on macOS.

## Tools

The shell environment is built around [zimfw][] and expects the following tools. Most are available via Homebrew.

### Required

| Tool | Description |
|------|-------------|
| [Homebrew](https://brew.sh) | macOS package manager; the `install` script syncs the Brewfile. |
| [GNU Stow](https://www.gnu.org/software/stow/) | Symlink farm manager; the `install` script uses it to link configs into place. |

[zimfw][] is fetched automatically by `.zshrc` on first run.

### Expected

These tools are used unconditionally — things may misbehave without them:

| Tool | Description |
|------|-------------|
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info display; bound to the `ff` function. |
| [fd](https://github.com/sharkdp/fd) | Friendly `find` replacement; used in the `fdh` function. |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder; integrated via Zim module (auto-installed by zimfw). |
| [lsd](https://github.com/lsd-rs/lsd) | Colorized `ls` replacement; used in listing aliases. |
| [nnn](https://github.com/jarun/nnn) | Terminal file browser; bound to the `n` alias. |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep replacement; used in the `alg` alias. |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer; the `t` function attaches to or creates sessions. |
| [yazi](https://github.com/sxyazi/yazi) | Terminal file manager with directory-change integration; bound to the `y` function. |

### Optional

These tools are detected at shell startup and skipped gracefully if absent:

| Tool | Description |
|------|-------------|
| [fnm](https://github.com/Schniz/fnm) | Fast Node.js version manager with automatic `.nvmrc` support. |
| [mise](https://github.com/jdx/mise) | Polyglot version manager for Node, Python, Go, and more. |
| [task](https://taskfile.dev) | Task runner that reads `Taskfile.yml` in the current directory. |
| [vivid](https://github.com/sharkdp/vivid) | Generates `LS_COLORS` for the Tokyo Night theme. |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` that learns your most-used directories. |

## Installation

To install, execute the following commands in a shell:

```bash
git clone git@github.com:dmdavis/dotfiles.git ~/.files
~/.files/install
```

Cheers! :beer:

[Bash-It]: https://github.com/Bash-it/bash-it
[Jeff Geerling's dotfiles]: https://github.com/geerlingguy/dotfiles/blob/master/.osx
[zimfw]: https://github.com/zimfw/zimfw
[zsh]: http://zsh.sourceforge.net