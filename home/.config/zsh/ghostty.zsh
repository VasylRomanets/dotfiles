ghostty-theme() {
  local config="$XDG_CONFIG_HOME/ghostty/config"
  local theme

  if [[ "$1" == "-r" ]]; then
    local themes=("$XDG_CONFIG_HOME/ghostty/themes"/*(N:t))
    theme=${themes[RANDOM % ${#themes[@]} + 1]}
  elif [[ -n "$1" && -f "$XDG_CONFIG_HOME/ghostty/themes/$1" ]]; then
    theme="$1"
  else
    theme=$(command ls "$XDG_CONFIG_HOME/ghostty/themes" | fzf --query="$1")
  fi

  [[ -z "$theme" ]] && return
  perl -i -pe "s/^theme = .*/theme = $theme/" "$config"
  killall -USR2 ghostty
  echo "$theme theme is applied."
}
