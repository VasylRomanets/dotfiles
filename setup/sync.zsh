#!/bin/zsh

# Syncs dotfiles — symlinks packages, sources shell files, copies assets.

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

linked=0
skipped=0
failed=0
copied=0

check_deps() {
  for cmd in toml2json jq; do
    command_exists "$cmd" || {
      error "$cmd not found — run bootstrap.zsh first!"
      exit 1
    }
  done
}

on_start() {
  require_macos
  check_deps
  echo "Creating symlinks and copying files..."
}

toml_get() {
  local file="$1" query="$2"
  [[ -f "$file" ]] || return
  toml2json "$file" | jq -r "$query // empty"
}

symlink() {
  local src="$1" dest="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    warning "$dest exists and is not a symlink — skipping"
    (( ++failed ))
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if ln -sf "$src" "$dest"; then
    (( ++linked ))
  else
    warning "Failed to symlink $dest"
    (( ++failed ))
  fi
}

run_hook() {
  local hook="$1" pkg="$2" label="$3"
  [[ -f "$hook" ]] || return
  echo "Running $label hook for $pkg..."
  if zsh "$hook"; then
    success "Ran $label hook for $pkg"
  else
    warning "$label hook failed for $pkg"
    (( ++failed ))
  fi
}

sync_packages() {
  cd "$DOTFILES"

  for pkg_dir in packages/*/; do
    pkg="$(basename "$pkg_dir")"
    setup="$pkg_dir/setup.toml"

    req_command="$(toml_get "$setup" '.requires.command')"
    req_app="$(toml_get "$setup" '.requires.app')"

    if [[ -n "$req_command" ]] && ! command_exists "$req_command"; then
      warning "Skipping $pkg — $req_command not found"
      (( ++skipped ))
      continue
    fi

    if [[ -n "$req_app" ]] && \
       [[ ! -d "/Applications/$req_app.app" ]] && \
       [[ ! -d "$HOME/Applications/$req_app.app" ]]; then
      warning "Skipping $pkg — $req_app not installed"
      (( ++skipped ))
      continue
    fi

    run_hook "$pkg_dir/hooks/pre-setup.zsh" "$pkg" "pre-setup"

    local pkg_linked=0

    if [[ -d "$pkg_dir/link" ]]; then
      link_target="$(toml_get "$setup" '.link.target')"
      link_target="${${link_target/#\~/$HOME}:-$HOME}"
      for src in "$pkg_dir/link/"**/*(.DN); do
        [[ "${src:t}" == ".DS_Store" ]] && continue
        rel="${src#$pkg_dir/link/}"
        symlink "$DOTFILES/$src" "$link_target/$rel"
      done
      pkg_linked=1
    fi

    if [[ -d "$pkg_dir/source" ]]; then
      source_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/source"
      mkdir -p "$source_dir"
      for src in "$pkg_dir/source/"*.zsh(N); do
        symlink "$DOTFILES/$src" "$source_dir/${src:t}"
      done
      pkg_linked=1
    fi

    if [[ -f "$pkg_dir/hooks/theme-changed.zsh" ]]; then
      theme_hooks_dir="${XDG_DATA_HOME:-$HOME/.local/share}/theme/hooks.d"
      mkdir -p "$theme_hooks_dir"
      symlink "$DOTFILES/$pkg_dir/hooks/theme-changed.zsh" "$theme_hooks_dir/$pkg.zsh"
      pkg_linked=1
    fi

    if (( pkg_linked )); then
      success "Linked $pkg"
    fi

    if [[ -d "$pkg_dir/copy" ]]; then
      copy_target="$(toml_get "$setup" '.copy.target')"
      copy_target="${copy_target/#\~/$HOME}"
      if [[ -n "$copy_target" ]]; then
        mkdir -p "$copy_target"
        for f in "$pkg_dir/copy/"**/*(.N); do
          [[ "${f:t}" == ".DS_Store" ]] && continue
          cp -f "$f" "$copy_target/"
          (( ++copied ))
        done
        success "Copied $pkg"
      fi
    fi

    run_hook "$pkg_dir/hooks/post-setup.zsh" "$pkg" "post-setup"
  done
}

ensure_default_theme() {
  # Guarantees a real theme is applied at least once — e.g. micro's
  # settings.json points at "current", a symlink the theme command manages, so
  # without this a fresh machine would show an undefined colorscheme until
  # the theme command is run by hand. Runs after sync_packages (not as a per-package
  # post-setup hook) so every package's hooks.d entry already exists —
  # package processing order is alphabetical, and "theme" sorts before
  # several packages (e.g. yazi) that it needs to have reacted.
  # Idempotent: only acts if no theme has ever been chosen.
  local state_file="${XDG_STATE_HOME:-$HOME/.local/state}/theme/current-theme.txt"
  local theme_cmd="$HOME/.local/bin/theme"
  [[ -s "$state_file" ]] && return
  [[ -x "$theme_cmd" ]] || return
  PATH="$HOME/.local/bin:$PATH" "$theme_cmd" rose-pine-moon
}

on_finish() {
  echo
  success "Done — $linked symlinks, $copied files copied, $skipped packages skipped, $failed conflicts."
}

main() {
  on_start
  sync_packages
  ensure_default_theme
  on_finish
}

main
