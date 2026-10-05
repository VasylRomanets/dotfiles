#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): writes delta's colors for the new
# theme into the file the tracked git config includes — git re-reads config on
# every invocation, so nothing else needs to happen here.
#
# delta's syntax-theme is the bat theme of that slug, <slug> or <slug>-generated. The tint behind added
# and removed lines is the theme's green or red blended into its background,
# which a Mustache template can't compute, so it's worked out here from the
# colors packages/theme/templates exports.
theme=$1

colors_file="${XDG_DATA_HOME:-$HOME/.local/share}/theme/colors/$theme.env"
[[ -r "$colors_file" ]] || {
  print -u2 "No exported colors for $theme: $colors_file"
  exit 1
}
source "$colors_file"

# Prints the color $1 moved $3 percent of the way toward $2 (hex, no '#').
blend() {
  local base=$1 toward=$2 percent=$3 out="" i
  for i in 0 2 4; do
    out+=$(printf '%02x' $(( (16#${base:$i:2} * (100 - percent) + 16#${toward:$i:2} * percent + 50) / 100 )))
  done
  print -r -- "$out"
}

bat_theme=$theme
[[ -e "${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes/$theme.tmTheme" ]] || bat_theme="$theme-generated"

git_delta_include="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated/delta.gitconfig"
mkdir -p "${git_delta_include:h}"
cat >"$git_delta_include" <<EOF
[delta]
  syntax-theme = "$bat_theme"
  minus-style = syntax "#$(blend $BG $RED 15)"
  minus-emph-style = syntax "#$(blend $BG $RED 30)"
  plus-style = syntax "#$(blend $BG $GREEN 15)"
  plus-emph-style = syntax "#$(blend $BG $GREEN 30)"
EOF
