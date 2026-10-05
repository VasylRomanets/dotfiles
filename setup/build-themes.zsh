#!/bin/zsh

# Regenerates the per-theme files of every package from the schemes.

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

SCHEMES_DIR="$DOTFILES/packages/theme/schemes"
SYNTAX_DIR="$DOTFILES/packages/theme/syntax"
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

# A theme can bring its own TextMate theme in packages/theme/syntax, for syntax
# colors a scheme can't match: a .tmTheme names any scope, a scheme only about
# 105 keys. It replaces the one generated for bat, and must run before the
# mirror below so yazi's previews use it too.
apply_syntax_themes() {
  local file
  for file in "$SYNTAX_DIR"/*.tmTheme(N); do
    if [[ ! -f "$SCHEMES_DIR/${${file:t}%.tmTheme}.toml" ]]; then
      warning "No scheme for syntax/${file:t}."
      continue
    fi
    cp "$file" "$DOTFILES/packages/bat/link/.config/bat/themes/${file:t}"
  done
}

# yazi flavors are generated into <slug>-generated.yazi, next to any flavor a
# theme's author wrote, which is named <slug>.yazi and wins (see the yazi hook).
# A generated copy such a flavor shadows would never be used, so it is dropped.
prune_shadowed_flavors() {
  local dir
  for dir in "$YAZI_FLAVORS"/*-generated.yazi(N/); do
    [[ -d "$YAZI_FLAVORS/${${dir:t}%-generated.yazi}.yazi" ]] && rm -rf "$dir"
  done
}

# yazi highlights previews with the same TextMate theme bat uses, but only
# looks for it inside the flavor directory. Flavors written by hand carry their
# own.
mirror_bat_themes_to_yazi() {
  local theme flavor_dir
  for theme in "$DOTFILES"/packages/bat/link/.config/bat/themes/*.tmTheme(N); do
    flavor_dir="$YAZI_FLAVORS/${${theme:t}%.tmTheme}-generated.yazi"
    [[ -d "$flavor_dir" ]] && cp "$theme" "$flavor_dir/tmtheme.xml"
  done
}

main() {
  check_deps
  [[ -d "$SCHEMES_DIR" ]] || { error "No schemes at $SCHEMES_DIR"; exit 1; }

  echo "Building themes..."

  build_packages
  apply_syntax_themes
  prune_shadowed_flavors
  mirror_bat_themes_to_yazi

  echo
  success "Done — built themes from $(ls "$SCHEMES_DIR" | wc -l | tr -d ' ') scheme(s)."
}

main
