# Claude Code Status Line

`statusline.sh` renders the Claude Code status line: model, thinking effort,
working directory, git branch, context-window usage, subagent dispatches,
lines changed, cost, elapsed time, and a short session ID.

```
⧉ Opus 5 │ high │  .files │  main │ ◕ 42% (84k/200k) │ ⚙ h4 o1 s10 │ +12/-3 │ $0.42 │ 15m │ ⏻ a1b2c3d4
```

Claude Code pipes a JSON blob to the script on stdin and prints whatever it
writes to stdout. Nothing here is machine-specific, so the same script runs
everywhere; only the wiring is per-machine.

## Setup on a new machine

The script is tracked here, but **`~/.claude/settings.json` is not** — it
carries per-machine `permissions`, `model`, and `effortLevel` values that
should not be shared. Wiring it up is a one-time manual step.

1. Install `jq`. It is a hard dependency — every field is parsed with it.

   ```sh
   brew install jq
   ```

2. Clone (or pull) this repo to `~/.files`:

   ```sh
   git clone git@github.com:dmdavis/dotfiles.git ~/.files
   ```

3. Add the `statusLine` key to `~/.claude/settings.json`:

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.files/claude/statusline.sh",
       "padding": 0
     }
   }
   ```

   Claude Code expands `~`, so the path needs no rewriting. Pointing at the
   repo instead of copying the script means a `git pull` is the whole update
   path.

   To merge it into an existing settings file without hand-editing:

   ```sh
   jq '.statusLine = {type: "command", command: "~/.files/claude/statusline.sh", padding: 0}' \
     ~/.claude/settings.json > ~/.claude/settings.json.new \
     && mv ~/.claude/settings.json.new ~/.claude/settings.json
   ```

4. Restart `claude`. Settings are read at startup.

## Verifying without launching Claude

Feed the script a sample payload directly — useful for confirming `jq` is
present and the exec bit survived the clone:

```sh
printf '%s' '{"model":{"display_name":"Opus 5"},"workspace":{"current_dir":"'"$HOME"'/.files"},"cost":{"total_cost_usd":0.42,"total_duration_ms":905000,"total_lines_added":12,"total_lines_removed":3},"session_id":"a1b2c3d4-e5f6","effort":{"level":"high"},"thinking":{"enabled":true},"context_window":{"context_window_size":200000,"total_input_tokens":84000,"used_percentage":42}}' \
  | ~/.files/claude/statusline.sh; echo
```

That should print the example line above, minus the `⚙` segment — the sample
session ID has no subagent transcripts on disk, so that segment is correctly
omitted.

## Troubleshooting

| Symptom | Cause |
|---------|-------|
| Status line blank or absent | `jq` not installed, or `claude` not restarted since the settings change. |
| `permission denied` | Exec bit lost. `chmod +x ~/.files/claude/statusline.sh`. |
| No context/effort segments | Older Claude Code that does not emit `.context_window` or `.effort`. The script degrades to empty rather than failing. |
| No branch segment | The working directory is not a git repo — expected. |

## Notes

- Colors are raw ANSI escapes; no external theme or dependency beyond `jq`.
- The context segment turns yellow at 50% and red with a `⚠` at 80%.
- Only the first 8 characters of the session ID are shown.
- The subagent segment (`⚙ h4 o1 s10`) counts Task/Agent dispatches this
  session, grouped by model — first letter plus count. A green `⚡n` appends
  when `n` subagent transcripts were written within the last minute, which
  approximates "still running". The harness JSON carries no subagent data, so
  this is read off disk from `~/.claude/projects/*/$session_id/subagents/`;
  the segment is absent for sessions that never dispatched one, including the
  sample payload above.
