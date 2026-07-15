# Dev-laptop (macOS) environment. Sourced from .zshenv when $OSTYPE is darwin*.
# Keep this SILENT and side-effect-free (no tty assumptions) — .zshenv runs on
# every shell invocation, including non-interactive ones (e.g. IDEs, scp).

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export HOMEBREW_NO_REQUIRE_TAP_TRUST=1

# Rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
export RUST_BACKTRACE=1
export RUST_LOG=info

# mise (polyglot version manager)
(( ${+commands[mise]} )) && eval "$(mise activate zsh)"
