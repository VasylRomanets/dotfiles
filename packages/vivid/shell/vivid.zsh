# Re-read the colors before each prompt when the theme hook has written new
# ones, so open shells follow a theme change without being restarted.
zmodload -F zsh/stat b:zstat

typeset -g _vivid_ls_colors_file="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated/ls_colors"
typeset -g _vivid_ls_colors_mtime=""

_vivid_reload_ls_colors() {
  local -a mtime
  zstat -A mtime +mtime "$_vivid_ls_colors_file" 2>/dev/null || return
  [[ "$mtime" == "$_vivid_ls_colors_mtime" ]] && return
  _vivid_ls_colors_mtime="$mtime"
  export LS_COLORS="$(<"$_vivid_ls_colors_file")"
}

_vivid_reload_ls_colors
autoload -Uz add-zsh-hook
add-zsh-hook precmd _vivid_reload_ls_colors
