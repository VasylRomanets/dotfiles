export NAVI_PATH="$XDG_CONFIG_HOME/navi/cheats"

# Puts the selected snippet on the next prompt line for editing instead of
# running it immediately, without a dedicated keybinding — no `bindkey`
# means no risk of colliding with fzf-git.zsh's ^g chord prefix.
navi() {
  local result
  result="$(command navi --print "$@")"
  [[ -n "$result" ]] && print -z -- "$result"
}
