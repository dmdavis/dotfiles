#!/usr/bin/env zsh
# NAS-DS918-PLUS machine environment. Sourced from .zshenv on every invocation,
# so keep it SILENT and side-effect-free.

# Expose SynoCommunity/SynoCli tools (/usr/local/bin) and Entware (/opt/bin),
# neither of which is on the DSM login PATH by default.
export PATH="/usr/local/bin:/opt/bin:$PATH"
