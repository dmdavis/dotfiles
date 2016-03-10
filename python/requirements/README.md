# PIP Requirements

This folder contains [pip][] requirement specification files for use with
[pip-tools][]. Requirements \*.txt files are generated in the corresponding
folders via `pip-compile`, but they are ignored by git.

| Specification                        | Purpose                                    |
|--------------------------------------|--------------------------------------------|
| [pyenv/python3.in](pyenv/python3.in) | Python 3.5+ packages used in everyday work |

[pip]:       https://pypi.python.org/pypi/pip
[pip-tools]: https://github.com/nvie/pip-tools
