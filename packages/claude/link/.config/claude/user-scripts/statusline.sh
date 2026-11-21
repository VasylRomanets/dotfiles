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

# One jq call reads every field. They come back joined by the ASCII unit
# separator, which no value contains, so an empty field keeps its place. The
# rate limits are only present for Pro/Max subscribers (or behind a spend-limit
# gateway), and only after the first API response in the session.
fields=$(printf '%s\n' "$input" | jq -r '[
  (.model.display_name // ""),
  (if (.context_window.used_percentage // 0) > 0 then .context_window.used_percentage else "" end),
  (.effort.level // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  ((.rate_limits.five_hour.resets_at // null) | if . == null then "" else floor end),
  ((.rate_limits.seven_day.resets_at // null) | if . == null then "" else floor end),
  (.cost.total_cost_usd // ""),
  ((.cost.total_duration_ms // 0) | . / 60000 | floor as $t | ($t / 1440 | floor) as $d | (($t % 1440) / 60 | floor) as $h | ($t % 60) as $m | (if $d > 0 then (($d | tostring) + "d ") else "" end) + (if $h > 0 then (($h | tostring) + "h ") else "" end) + (($m | tostring) + "m")),
  (.cost.total_lines_added // ""),
  (.cost.total_lines_removed // "")
] | map(tostring) | join("\u001f")')
IFS=$(printf '\037') read -r model used_pct_raw effort five_hour_pct seven_day_pct \
  five_hour_reset_epoch seven_day_reset_epoch cost duration added removed <<EOF
$fields
EOF
five_hour_reset=""
seven_day_reset=""
[ -n "$five_hour_reset_epoch" ] && five_hour_reset=$(format_countdown "$five_hour_reset_epoch")
[ -n "$seven_day_reset_epoch" ] && seven_day_reset=$(format_countdown "$seven_day_reset_epoch")

dim='\033[2m'
reset='\033[0m'

if [ -n "$used_pct_raw" ]; then
  printf "${dim}%.0f%%${reset}" "$used_pct_raw"
else
  printf "${dim}?%%${reset}"
fi

if [ -n "$five_hour_pct" ] || [ -n "$seven_day_pct" ]; then
  # shellcheck disable=SC2059
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
  # shellcheck disable=SC2059
  printf "${reset}"
fi

[ -n "$cost" ]                       && printf "${dim} • \$%.2f${reset}"  "$cost"
[ -n "$duration" ]                   && printf "${dim} • %s${reset}"      "$duration"
[ -n "$added" ] && [ -n "$removed" ] && printf "${dim} • +%s/-%s${reset}" "$added" "$removed"
[ -n "$model" ]                      && printf "${dim} • %s${reset}"      "$model"
[ -n "$effort" ]                     && printf "${dim} • %s${reset}"      "$effort"
