#!/bin/zsh

# Regenerates the per-theme files of every package from the Tinted8 schemes.

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

SCHEMES_DIR="$DOTFILES/packages/theme/schemes"

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

# Files a package lists in templates/keep-themes.txt (globs relative to the
# package) are maintained by hand, typically upstream themes that beat what a
# scheme can express. The builder would overwrite them, so they are saved before
# the build and put back at the end.
save_kept_files() {
  local keep pattern file
  for keep in "$DOTFILES"/packages/*/templates/keep-themes.txt(N); do
    while IFS= read -r pattern; do
      [[ -z "$pattern" || "$pattern" == \#* ]] && continue
      for file in "${keep:h:h}"/${~pattern}(N.); do
        mkdir -p "$KEPT_DIR/${${file#$DOTFILES/}:h}"
        cp -p "$file" "$KEPT_DIR/${file#$DOTFILES/}"
      done
    done <"$keep"
  done
}

restore_kept_files() {
  cp -Rp "$KEPT_DIR/." "$DOTFILES/"
}

# yazi highlights previews with the same TextMate theme bat uses, but only
# looks for it inside the flavor directory.
mirror_bat_themes_to_yazi() {
  local theme flavor_dir
  for theme in "$DOTFILES"/packages/bat/link/.config/bat/themes/*.tmTheme(N); do
    flavor_dir="$DOTFILES/packages/yazi/link/.config/yazi/flavors/${${theme:t}%.tmTheme}.yazi"
    [[ -d "$flavor_dir" ]] && cp "$theme" "$flavor_dir/tmtheme.xml"
  done
}

main() {
  check_deps
  [[ -d "$SCHEMES_DIR" ]] || { error "No schemes at $SCHEMES_DIR"; exit 1; }

  echo "Building themes..."

  local marker
  marker="$(mktemp)"
  KEPT_DIR="$(mktemp -d)"
  trap 'rm -rf "$marker" "$KEPT_DIR"' EXIT

  save_kept_files
  build_packages
  check_output "$marker"
  mirror_bat_themes_to_yazi
  restore_kept_files

  echo
  success "Done — built themes from $(ls "$SCHEMES_DIR" | wc -l | tr -d ' ') scheme(s)."
}

main
