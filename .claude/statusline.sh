#!/bin/sh
# Claude Code statusline — reads JSON from stdin and prints a dim one-line summary.
# Fields: context usage %, session cost, session duration, lines added/removed, model, effort level.
# Invoked automatically by Claude Code after each turn via settings.json statusLine.command.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct_raw=$(echo "$input" | jq -r 'if (.context_window.used_percentage // 0) > 0 then .context_window.used_percentage else "" end')
effort=$(echo "$input" | jq -r '.effort.level // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration=$(echo "$input" | jq -r '(.cost.total_duration_ms // 0) | . / 60000 | floor as $t | ($t / 1440 | floor) as $d | (($t % 1440) / 60 | floor) as $h | ($t % 60) as $m | (if $d > 0 then (($d | tostring) + "d ") else "" end) + (if $h > 0 then (($h | tostring) + "h ") else "" end) + (($m | tostring) + "m")')
added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')

dim='\033[2m'
reset='\033[0m'

if [ -n "$used_pct_raw" ]; then
    printf "${dim}%.0f%%${reset}" "$used_pct_raw"
else
    printf "${dim}?%%${reset}"
fi
[ -n "$cost" ]                       && printf "${dim} • \$%.2f${reset}"  "$cost"
[ -n "$duration" ]                   && printf "${dim} • %s${reset}"      "$duration"
[ -n "$added" ] && [ -n "$removed" ] && printf "${dim} • +%s/-%s${reset}" "$added" "$removed"
[ -n "$model" ]                      && printf "${dim} • %s${reset}"      "$model"
[ -n "$effort" ]                     && printf "${dim} • %s${reset}"      "$effort"
