#!/bin/sh

# Claude Code statusline — reads JSON from stdin and prints a dim one-line summary.
# Fields: context usage %, 5h/7d rate-limit usage with reset countdowns, session cost,
# session duration, lines added/removed, model, effort level.
# Invoked automatically by Claude Code after each turn via settings.json statusLine.command.

# Formats a countdown to a future Unix-epoch-seconds timestamp as "Xd Xh Xm", omitting
# leading zero units (but always keeping minutes) to match the session-duration format below.
format_countdown() {
    diff=$(($1 - now))
    [ "$diff" -lt 0 ] && diff=0
    total_min=$((diff / 60))
    d=$((total_min / 1440))
    h=$(((total_min % 1440) / 60))
    m=$((total_min % 60))
    out=""
    [ "$d" -gt 0 ] && out="${d}d "
    [ "$h" -gt 0 ] && out="${out}${h}h "
    printf '%s' "${out}${m}m"
}

input=$(cat)
now=$(date +%s)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct_raw=$(echo "$input" | jq -r 'if (.context_window.used_percentage // 0) > 0 then .context_window.used_percentage else "" end')
effort=$(echo "$input" | jq -r '.effort.level // empty')
# Only present for Pro/Max subscribers (or behind a spend-limit gateway), and only
# after the first API response in the session — absent otherwise.
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_hour_reset_epoch=$(echo "$input" | jq -r '(.rate_limits.five_hour.resets_at // empty) | floor')
seven_day_reset_epoch=$(echo "$input" | jq -r '(.rate_limits.seven_day.resets_at // empty) | floor')
five_hour_reset=""
seven_day_reset=""
[ -n "$five_hour_reset_epoch" ] && five_hour_reset=$(format_countdown "$five_hour_reset_epoch")
[ -n "$seven_day_reset_epoch" ] && seven_day_reset=$(format_countdown "$seven_day_reset_epoch")
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

if [ -n "$five_hour_pct" ] || [ -n "$seven_day_pct" ]; then
    printf "${dim} • "
    if [ -n "$five_hour_pct" ]; then
        printf "5h:%.0f%%" "$five_hour_pct"
        [ -n "$five_hour_reset" ] && printf " (resets in %s)" "$five_hour_reset"
    fi
    [ -n "$five_hour_pct" ] && [ -n "$seven_day_pct" ] && printf " "
    if [ -n "$seven_day_pct" ]; then
        printf "7d:%.0f%%" "$seven_day_pct"
        [ -n "$seven_day_reset" ] && printf " (resets in %s)" "$seven_day_reset"
    fi
    printf "${reset}"
fi

[ -n "$cost" ]                       && printf "${dim} • \$%.2f${reset}"  "$cost"
[ -n "$duration" ]                   && printf "${dim} • %s${reset}"      "$duration"
[ -n "$added" ] && [ -n "$removed" ] && printf "${dim} • +%s/-%s${reset}" "$added" "$removed"
[ -n "$model" ]                      && printf "${dim} • %s${reset}"      "$model"
[ -n "$effort" ]                     && printf "${dim} • %s${reset}"      "$effort"
