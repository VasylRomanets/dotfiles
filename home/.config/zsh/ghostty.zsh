ghostty-theme() {
  local config="$XDG_CONFIG_HOME/ghostty/config"
  local theme
  theme=$(command ls "$XDG_CONFIG_HOME/ghostty/themes" | fzf --query="$1")
  [[ -z "$theme" ]] && return
  perl -i -pe "s/^theme = .*/theme = $theme/" "$config"
  killall -USR2 ghostty
  echo "$theme theme is applied."
}
