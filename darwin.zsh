# Interactive macOS configuration. Sourced from .zshrc, so unlike
# env.darwin.zsh this may assume a tty and produce output.

# ------------
# Postgres.app
# ------------
#
# When the collation data underneath a cluster changes, text indexes are left
# sorted the old way — queries can silently miss rows and UNIQUE columns can
# hold duplicates. Postgres.app detects this and warns that databases must be
# reindexed. The server itself can't: macOS libc reports no collation version,
# so pg_database.datcollversion is NULL. Instead the app hashes the collation
# behaviour on every start and records the hashes it has seen in
# <data dir>/postgresapp_config.plist. These helpers read that same state.
#
# Set PGAPP_REINDEX_AUTO=1 to reindex automatically instead of being nagged.

PGAPP_PREFS="$HOME/Library/Preferences/com.postgresapp.Postgres2.plist"
PGAPP_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/pgapp-reindex"

# Print "binPath<TAB>varPath<TAB>port" for each server configured in the app.
_pgapp_servers() {
  local bin var port
  local -i i=0
  while bin=$(plutil -extract "Servers.$i.binPath" raw -o - "$PGAPP_PREFS" 2>/dev/null); do
    var=$(plutil -extract "Servers.$i.varPath" raw -o - "$PGAPP_PREFS" 2>/dev/null)
    port=$(plutil -extract "Servers.$i.port" raw -o - "$PGAPP_PREFS" 2>/dev/null)
    print -r -- "$bin"$'\t'"$var"$'\t'"$port"
    (( i++ ))
  done
}

# Path to the cached server list, refreshing it if Postgres.app's prefs moved
# on. plutil is too slow to run on every shell start.
_pgapp_server_cache() {
  local cache="$PGAPP_STATE/servers"
  if [[ ! -r $cache || $PGAPP_PREFS -nt $cache ]]; then
    [[ -d $PGAPP_STATE ]] || mkdir -p "$PGAPP_STATE"
    _pgapp_servers >| "$cache"
  fi
  print -r -- "$cache"
}

# Print the collation hashes recorded for the data directory $1, oldest first.
_pgapp_hashes() {
  local cfg="$1/postgresapp_config.plist" h
  local -i i=0
  while h=$(plutil -extract "recently_started_collation_hash.$i" raw -o - "$cfg" 2>/dev/null); do
    print -r -- "$h"
    (( i++ ))
  done
}

# Return 0 if the cluster with data directory $1 wants reindexing.
_pgapp_needs_reindex() {
  local -a hashes
  hashes=(${(f)"$(_pgapp_hashes "$1")"})
  (( $#hashes )) || return 1

  local done_hash="" stamp="$PGAPP_STATE/${1:t}.reindexed"
  [[ -r $stamp ]] && done_hash=$(<"$stamp")

  if [[ -n $done_hash ]]; then
    # Anything but the hash we last reindexed against means it changed again.
    [[ ${hashes[-1]} != $done_hash ]]
  else
    # Never reindexed here: the app warns once it has seen the data directory
    # sort two different ways.
    (( ${#${(u)hashes}} > 1 ))
  fi
}

# Record that the cluster with data directory $1 is now current.
_pgapp_stamp() {
  [[ -d $PGAPP_STATE ]] || mkdir -p "$PGAPP_STATE"
  _pgapp_hashes "$1" | tail -1 >| "$PGAPP_STATE/${1:t}.reindexed"
  : >| "$PGAPP_STATE/${1:t}.checked"
}

# Clear recorded collation version mismatches, which is what stops the server
# warning on every connect. Usually a no-op for the databases themselves, but
# Postgres.app ships its own ICU, so app updates do shift ICU collations.
_pgapp_refresh_collations() {
  local bin=$1 port=$2 db
  local -a dbs

  dbs=(${(f)"$("$bin/psql" -d postgres -p "$port" -AtqX -c "
    SELECT datname FROM pg_database
     WHERE datallowconn
       AND datcollversion IS DISTINCT FROM pg_database_collation_actual_version(oid)")"})
  for db in $dbs; do
    "$bin/psql" -d postgres -p "$port" -qX \
      -c "ALTER DATABASE \"${db//\"/\"\"}\" REFRESH COLLATION VERSION"
  done

  dbs=(${(f)"$("$bin/psql" -d postgres -p "$port" -AtqX -c "
    SELECT datname FROM pg_database WHERE datallowconn")"})
  for db in $dbs; do
    "$bin/psql" -d "$db" -p "$port" -qX -c "
      DO \$\$
      DECLARE c record;
      BEGIN
        FOR c IN SELECT oid::regcollation AS name FROM pg_collation
                  WHERE collversion IS NOT NULL
                    AND collversion <> pg_collation_actual_version(oid)
        LOOP
          EXECUTE format('ALTER COLLATION %s REFRESH VERSION', c.name);
        END LOOP;
      END
      \$\$;"
  done
}

# Do what More Info → "Hide This Warning" does in the app's UI.
_pgapp_clear_warning() {
  local bin=$1 port=$2 cfg="$3/postgresapp_config.plist" pgver
  [[ -w $cfg ]] || return 1
  # server_version reads "17.10 (Postgres.app)"; the app records just "17.10".
  pgver=$("$bin/psql" -d postgres -p "$port" -AtqX -c 'SHOW server_version')
  pgver=${pgver%% *}
  cp -p "$cfg" "$cfg.bak" &&
    plutil -replace reindex_warning_reset_on_macos_version \
      -string "$(sw_vers -productVersion)" "$cfg" &&
    plutil -replace reindex_warning_reset_on_postgresql_version \
      -string "$pgver" "$cfg"
}

# Rebuild the indexes Postgres.app is warning about, on every server it knows.
#
#   pgapp-reindex [-f|--force] [-n|--check] [--no-hide]
pgapp-reindex() {
  emulate -L zsh
  local arg bin var port
  local -i force=0 hide=1 check=0

  for arg; do
    case $arg in
      -f|--force) force=1 ;;
      -n|--check) check=1 ;;
      --no-hide)  hide=0 ;;
      *) print -u2 "pgapp-reindex: unknown option: $arg"; return 2 ;;
    esac
  done

  if [[ ! -r $PGAPP_PREFS ]]; then
    print -u2 "pgapp-reindex: Postgres.app is not configured on this machine"
    return 1
  fi

  while IFS=$'\t' read -r bin var port; do
    if ! _pgapp_needs_reindex "$var" && (( ! force )); then
      print "pgapp-reindex: port $port is up to date"
      continue
    fi
    if (( check )); then
      print "pgapp-reindex: port $port needs reindexing"
      continue
    fi
    if ! "$bin/pg_isready" -q -p "$port"; then
      print -u2 "pgapp-reindex: nothing listening on port $port — start it in Postgres.app"
      continue
    fi

    print "pgapp-reindex: reindexing every database on port $port, this can take a while"
    if ! "$bin/reindexdb" --all --system --port "$port" ||
       ! "$bin/reindexdb" --all --port "$port"; then
      print -u2 "pgapp-reindex: reindex failed on port $port, leaving the warning in place"
      continue
    fi

    _pgapp_refresh_collations "$bin" "$port"
    (( hide )) && _pgapp_clear_warning "$bin" "$port" "$var"
    _pgapp_stamp "$var"
    print "pgapp-reindex: port $port done"
  done < "$(_pgapp_server_cache)"
}

# Re-examine a cluster only when Postgres.app has rewritten its config, i.e.
# when the server has been restarted since the last look. Everything else is
# reading mtimes, so the common case costs nothing.
_pgapp_reindex_check() {
  emulate -L zsh
  [[ -r $PGAPP_PREFS ]] || return 0

  local bin var port checked
  while IFS=$'\t' read -r bin var port; do
    # Note zsh's -nt is false when the second file is missing, unlike bash.
    checked="$PGAPP_STATE/${var:t}.checked"
    [[ ! -e $checked || "$var/postgresapp_config.plist" -nt $checked ]] || continue
    if _pgapp_needs_reindex "$var"; then
      if (( ${PGAPP_REINDEX_AUTO:-0} )); then
        pgapp-reindex
        continue
      fi
      print -u2 "Postgres.app: collation data changed on port $port — databases need reindexing (run: pgapp-reindex)"
    fi
    [[ -d $PGAPP_STATE ]] || mkdir -p "$PGAPP_STATE"
    : >| "$PGAPP_STATE/${var:t}.checked"
  done < "$(_pgapp_server_cache)"
}

# ---------------
# Preferred tools
# ---------------
#
# Verifies the fast tools listed in the Preferred Tools table of CLAUDE.md
# are on PATH. `plutil` ships with macOS, so it's checked but never reported
# as missing/installable.

dotfiles-check-tools() {
  emulate -L zsh
  local -A tools=(
    rg       "brew install ripgrep"
    fd       "brew install fd"
    trash    "brew install trash"
    yq       "brew install yq"
    jq       "brew install jq"
    xq       "brew install yq"
    plutil   "(built-in)"
    glow     "brew install glow"
    lsd      "brew install lsd"
    bat      "brew install bat"
    gh       "brew install gh"
    defuddle "npm i -g defuddle-cli"
  )

  local tool hint missing=0
  local -a lines
  for tool hint in "${(@kv)tools}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      lines+=("✓ $tool")
    else
      lines+=("✗ $tool${hint:+ — $hint}")
      (( missing++ ))
    fi
  done
  print -l -- "${(@on)lines}"

  return $(( missing > 0 ))
}

# --------
# Obsidian
# --------
#
# Keeps Obsidian templates in sync between independent vaults (home vs. the
# GEICO work vault) via this repo, since they can't share Obsidian Sync.
# $OBSIDIAN_VAULT_DIR is set per-machine in machines/$HOSTNAME/env.zsh.
# Copy only — no symlink, since iCloud's Files provider doesn't handle those
# reliably, and the work vault is a separate iCloud/Sync account anyway.
#
# The template itself depends on the templater-obsidian, dataview, and
# customjs plugins (customjs supplies cJS()/Widgets, used by the daily-quote
# block) — install those in the destination vault or that block will error.

obsidian-template-push() {
  emulate -L zsh
  if [[ -z "$OBSIDIAN_VAULT_DIR" ]]; then
    print -u2 "obsidian-template-push: \$OBSIDIAN_VAULT_DIR is not set"
    return 1
  fi
  local vault_file="$OBSIDIAN_VAULT_DIR/Resources/Obsidian/Templates/Daily Note Template.md"
  local repo_file="$DOTFILES/obsidian/templates/Daily Note Template.md"
  if [[ ! -f "$vault_file" ]]; then
    print -u2 "obsidian-template-push: not found: $vault_file"
    return 1
  fi
  cp "$vault_file" "$repo_file"
  print "obsidian-template-push: copied to $repo_file — commit it in \$DOTFILES"
}

obsidian-template-pull() {
  emulate -L zsh
  if [[ -z "$OBSIDIAN_VAULT_DIR" ]]; then
    print -u2 "obsidian-template-pull: \$OBSIDIAN_VAULT_DIR is not set"
    return 1
  fi
  git -C "$DOTFILES" pull --ff-only || return 1
  local repo_file="$DOTFILES/obsidian/templates/Daily Note Template.md"
  local vault_file="$OBSIDIAN_VAULT_DIR/Resources/Obsidian/Templates/Daily Note Template.md"
  if [[ ! -f "$repo_file" ]]; then
    print -u2 "obsidian-template-pull: not found: $repo_file"
    return 1
  fi
  cp "$repo_file" "$vault_file"
  print "obsidian-template-pull: copied to $vault_file"
}

[[ -o interactive ]] && _pgapp_reindex_check
