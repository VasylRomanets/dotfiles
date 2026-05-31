# if old aliases exist from a previous session it will error
unalias cpucheck ramcheck batcheck diskcheck ipcheck syscheck 2>/dev/null

cpucheck() {
  top -l 1 -s 0 | grep 'CPU usage' | awk '{print $3 " (User) / " $5 " (Sys)"}'
}

ramcheck() {
  local used="$(top -l 1 -s 0 | grep PhysMem | awk '{print $2}' | tr -d 'G')"
  local total="$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024}')"
  awk -v u="$used" -v t="$total" 'BEGIN {printf "%.1f / %.0fG\n", u, t}'
}

batcheck() {
  local pct="$(pmset -g batt | grep -o '[0-9]*%' | head -n1)"
  local cycles="$(system_profiler SPPowerDataType | grep 'Cycle Count' | awk '{print $3}')"
  echo "$pct / $cycles cycles"
}

diskcheck() {
  df -k / | awk 'NR==2 {
    free  = $4 * 1024 / 1e9
    total = ($3 + $4) * 1024 / 1e9
    printf "%.1fG free / %.1fG total\n", free, total
  }'
}

ipcheck() {
  local local_ip="$(ipconfig getifaddr en0 || ipconfig getifaddr en1 || echo 'No Local IP')"
  local public_ip="$(curl -s --max-time 2 ifconfig.me || echo 'Offline')"
  echo "$local_ip | $public_ip"
}

syscheck() {
  echo
  echo "\x1B[1m--- SYSTEM DIAGNOSTICS ---\x1B[0m"
  echo -n "⚙️ CPU:   "; cpucheck
  echo -n "🧠 RAM:   "; ramcheck
  echo -n "🔋 BAT:   "; batcheck
  echo -n "💾 DISK:  "; diskcheck
  echo -n "🌐 IP:    "; ipcheck
  echo "\x1B[1m--------------------------\x1B[0m"
  echo
}
