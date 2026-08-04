#!/usr/bin/env bash
# Claude Code status line — session-state awareness at a glance.
# Receives a JSON blob on stdin (see: docs statusLine schema). Requires jq.

input=$(cat)

# --- ANSI helpers -----------------------------------------------------------
DIM=$'\033[2m'; RST=$'\033[0m'
GRN=$'\033[32m'; YEL=$'\033[33m'; RED=$'\033[31m'; CYN=$'\033[36m'; MAG=$'\033[35m'; BLU=$'\033[34m'
SEP="${DIM} │ ${RST}"

# --- Fields from the harness JSON ------------------------------------------
model=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")
cwd=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
cost=$(jq -r '.cost.total_cost_usd // 0' <<<"$input")
dur_ms=$(jq -r '.cost.total_duration_ms // 0' <<<"$input")
added=$(jq -r '.cost.total_lines_added // 0' <<<"$input")
removed=$(jq -r '.cost.total_lines_removed // 0' <<<"$input")
session=$(jq -r '.session_id // ""' <<<"$input")
effort=$(jq -r '.effort.level // ""' <<<"$input")
thinking_on=$(jq -r '.thinking.enabled // false' <<<"$input")

# --- Git branch -------------------------------------------------------------
branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- Live context-window usage (harness-reported, tracks the active model) --
ctx_str=""
ctx_limit=$(jq -r '.context_window.context_window_size // 0' <<<"$input")
if [ "$ctx_limit" -gt 0 ] 2>/dev/null; then
  tokens=$(jq -r '.context_window.total_input_tokens // 0' <<<"$input")
  pct=$(jq -r '.context_window.used_percentage // 0' <<<"$input")
  warn=""
  if   [ "$pct" -ge 80 ]; then col=$RED; warn=" ⚠"
  elif [ "$pct" -ge 50 ]; then col=$YEL
  else col=$GRN; fi
  # compact k-format, e.g. 84k
  k=$(( tokens / 1000 ))
  limit_k=$(( ctx_limit / 1000 ))
  ctx_str="${col}◕ ${pct}% ${DIM}(${k}k/${limit_k}k)${col}${warn}${RST}"
fi

# --- Subagent dispatches (Task/Agent tool; e.g. Superpowers stage 4) --------
# The harness JSON carries no subagent data, so read it off disk instead. Each
# dispatch writes agent-<id>.meta.json (agentType, description, model) beside
# its transcript. Glob by session_id rather than re-deriving the encoded
# project-dir name from cwd — the id is unique and the encoding is lossy.
agents_str=""
if [ -n "$session" ]; then
  subdir=""
  for d in "$HOME"/.claude/projects/*/"$session"/subagents; do
    [ -d "$d" ] && { subdir="$d"; break; }
  done
  if [ -n "$subdir" ]; then
    # Cumulative dispatches this session, grouped by model: "h4 o1 s10"
    breakdown=$(jq -rs 'map(.model // "?")
                        | group_by(.)
                        | map("\(.[0] | .[0:1])\(length)")
                        | join(" ")' "$subdir"/*.meta.json 2>/dev/null)
    # Transcripts written to within the last minute ≈ still running.
    # BSD find: use -mmin, NOT -newermt with a relative string (misparses).
    live=$(find "$subdir" -name '*.jsonl' -mmin -1 2>/dev/null | wc -l | tr -d ' ')
    if [ -n "$breakdown" ]; then
      agents_str="${MAG}⚙ ${breakdown}${RST}"
      if [ "${live:-0}" -gt 0 ] 2>/dev/null; then
        agents_str="${agents_str}${GRN} ⚡${live}${RST}"
      fi
    fi
  fi
fi

# --- Thinking level ----------------------------------------------------------
think_str=""
if [ "$thinking_on" = "true" ] && [ -n "$effort" ]; then
  case "$effort" in
    low)    think_col=$GRN ;;
    medium) think_col=$YEL ;;
    high|max) think_col=$RED ;;
    *)      think_col=$RST ;;
  esac
  think_str="${think_col}${effort}${RST}"
else
  think_str="${DIM}off${RST}"
fi

# --- Cost + duration --------------------------------------------------------
cost_str=$(printf '$%.2f' "$cost")
mins=$(( dur_ms / 60000 ))
if [ "$mins" -ge 60 ]; then
  dur_str=$(printf '%dh%02dm' $(( mins / 60 )) $(( mins % 60 )))
else
  dur_str="${mins}m"
fi

# --- Assemble ---------------------------------------------------------------
out="${MAG}⧉ ${model}${RST}"
out="${out}${SEP}${think_str}"
[ -n "$cwd" ]     && out="${out}${SEP}${BLU} ${cwd##*/}${RST}"
[ -n "$branch" ]  && out="${out}${SEP}${CYN} ${branch}${RST}"
[ -n "$ctx_str" ] && out="${out}${SEP}${ctx_str}"
[ -n "$agents_str" ] && out="${out}${SEP}${agents_str}"
if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
  out="${out}${SEP}${GRN}+${added}${RST}/${RED}-${removed}${RST}"
fi
out="${out}${SEP}${DIM}${cost_str}${RST}"
out="${out}${SEP}${DIM}${dur_str}${RST}"
[ -n "$session" ] && out="${out}${SEP}${DIM}⏻ ${session:0:8}${RST}"

printf '%s' "$out"
