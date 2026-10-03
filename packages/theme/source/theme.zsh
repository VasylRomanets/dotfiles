THEME_STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/theme/current-theme.txt"

# Prints the active theme slug set by theme-set, defaulting to Rose Pine Moon.
current_theme() {
  local theme=""
  [[ -f $THEME_STATE_FILE ]] && theme=$(<"$THEME_STATE_FILE")
  print -r -- "${theme:-rose-pine-moon}"
}
