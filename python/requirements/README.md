# PIP Requirements

This folder contains [pip][] requirement specification files for use with
[pip-tools][]. Requirements \*.txt files are generated in the corresponding
folders via `pip-compile`, but they are ignored by git.

| Specification                              | Purpose                                      |
|--------------------------------------------|----------------------------------------------|
| [homebrew/python2.in](homebrew/python2.in) | Python 2.7 packages for Homebrew Python      |
| [pyenv/openstack.in](pyenv/openstack.in)   | Python 2.7 packages used to manage OpenStack |
| [pyenv/python2.in](pyenv/python2.in)       | Python 2.7 packages used in everyday work    |
| [pyenv/python3.in](pyenv/python3.in)       | Python 3.5+ packages used in everyday work   |

[pip]:       https://pypi.python.org/pypi/pip
[pip-tools]: https://github.com/nvie/pip-tools
