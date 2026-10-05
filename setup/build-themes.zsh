#!/bin/zsh

# Regenerates the per-theme files of every package from the schemes.

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

SCHEMES_DIR="$DOTFILES/packages/theme/schemes"
BAT_THEMES="$DOTFILES/packages/bat/link/.config/bat/themes"
YAZI_FLAVORS="$DOTFILES/packages/yazi/link/.config/yazi/flavors"

check_deps() {
  command_exists python3 || {
    error "python3 not found."
    exit 1
  }
}

# Renders every package that has templates/config.toml, once per scheme. The
# renderer stops at a placeholder with no value or a color that isn't #rrggbb.
build_packages() {
  local packages=("$DOTFILES"/packages/*/templates/config.toml(N:h:h))
  python3 "$DOTFILES/packages/theme/tools/render-themes.py" "$SCHEMES_DIR" "${packages[@]}" || {
    error "Building themes failed."
    exit 1
  }
}

# Themes are generated as <slug>-generated, next to anything a person supplied
# as <slug>: an upstream .tmTheme for bat, a flavor a theme's author wrote for
# yazi. The supplied one wins (see the bat and yazi hooks), so a generated copy
# it shadows would never be used, and is dropped.
prune_shadowed() {
  local dir=$1 extension=$2 generated
  for generated in "$dir"/*-generated.$extension(N); do
    [[ -e "${generated%-generated.$extension}.$extension" ]] && rm -rf "$generated"
  done
}

# yazi highlights previews with the same TextMate theme bat uses, but only
# looks for it inside the flavor directory. Flavors written by hand carry their
# own.
mirror_bat_themes_to_yazi() {
  local flavor_dir slug theme
  for flavor_dir in "$YAZI_FLAVORS"/*-generated.yazi(N/); do
    slug="${${flavor_dir:t}%-generated.yazi}"
    theme="$BAT_THEMES/$slug.tmTheme"
    [[ -f "$theme" ]] || theme="$BAT_THEMES/$slug-generated.tmTheme"
    cp "$theme" "$flavor_dir/tmtheme.xml"
  done
}

main() {
  check_deps
  [[ -d "$SCHEMES_DIR" ]] || { error "No schemes at $SCHEMES_DIR"; exit 1; }

  echo "Building themes..."

  build_packages
  prune_shadowed "$BAT_THEMES" tmTheme
  prune_shadowed "$YAZI_FLAVORS" yazi
  mirror_bat_themes_to_yazi

  echo
  success "Done — built themes from $(ls "$SCHEMES_DIR" | wc -l | tr -d ' ') scheme(s)."
}

main
