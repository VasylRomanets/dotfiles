#!/bin/zsh

# Regenerates the per-theme files of every package from the Tinted8 schemes.

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

SCHEMES_DIR="$DOTFILES/packages/theme/schemes"
SYNTAX_DIR="$DOTFILES/packages/theme/syntax"
YAZI_FLAVORS="$DOTFILES/packages/yazi/link/.config/yazi/flavors"

# The template variable names this repo's templates use are those of
# tinted-builder 0.21 (they differ from newer drafts of the Tinted8 spec).
BUILDER_SERIES="0.21"

check_deps() {
  command_exists tinted-builder-rust || {
    error "tinted-builder-rust not found."
    error "Download it from github.com/tinted-theming/tinted-builder-rust/releases"
    error "or run: cargo install tinted-builder-rust --version '~$BUILDER_SERIES'"
    exit 1
  }
  command_exists perl || {
    error "perl not found."
    exit 1
  }
  tinted-builder-rust --version | grep -q " $BUILDER_SERIES\." || \
    warning "Expected tinted-builder-rust $BUILDER_SERIES.x, got: $(tinted-builder-rust --version)"
}

# Builds every package that has a templates/config.yaml. The builder writes
# each rendered file relative to the package directory.
build_packages() {
  local config pkg_dir
  for config in "$DOTFILES"/packages/*/templates/config.yaml(N); do
    pkg_dir="${config:h:h}"
    tinted-builder-rust build "$pkg_dir" --schemes-dir "$SCHEMES_DIR" --quiet || {
      error "Building themes for ${pkg_dir:t} failed."
      exit 1
    }
  done
}

# A variable the builder cannot resolve renders as nothing, which leaves a
# bare '#' (or an empty value) where a color belongs. Flag those instead of
# shipping a broken theme.
check_output() {
  local marker="$1" broken
  broken="$(find "$DOTFILES"/packages/*/link -type f -newer "$marker" -print0 \
    | xargs -0 perl -ne 'print "$ARGV:$.: $_" if /(?<=[>":,=])#(?![0-9a-fA-F]{6})/ || /=\x27\x27$/ || /:\s+""$/ || /\{\{|\}\}/')"
  [[ -z "$broken" ]] && return
  error "Unresolved template variables in the generated files:"
  echo "$broken" | head -20
  exit 1
}

# A theme can bring its own TextMate theme in packages/theme/syntax, for syntax
# colors a scheme can't match: a .tmTheme names any scope, a scheme only about
# 105 keys. It replaces the one generated for bat, and must run before the
# mirror below so yazi's previews use it too.
apply_syntax_themes() {
  local file
  for file in "$SYNTAX_DIR"/*.tmTheme(N); do
    if [[ ! -f "$SCHEMES_DIR/${${file:t}%.tmTheme}.yaml" ]]; then
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

  local marker
  marker="$(mktemp)"
  trap 'rm -f "$marker"' EXIT

  build_packages
  check_output "$marker"
  apply_syntax_themes
  prune_shadowed_flavors
  mirror_bat_themes_to_yazi

  echo
  success "Done — built themes from $(ls "$SCHEMES_DIR" | wc -l | tr -d ' ') scheme(s)."
}

main
