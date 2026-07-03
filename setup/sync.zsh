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
    command -v "$cmd" &>/dev/null || {
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

sync_packages() {
  cd "$DOTFILES"

  for pkg_dir in packages/*/; do
    pkg="$(basename "$pkg_dir")"
    setup="$pkg_dir/setup.toml"

    req_command="$(toml_get "$setup" '.requires.command')"
    req_app="$(toml_get "$setup" '.requires.app')"

    if [[ -n "$req_command" ]] && ! command -v "$req_command" &>/dev/null; then
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

    if [[ -d "$pkg_dir/shell" ]]; then
      source_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/source"
      mkdir -p "$source_dir"
      for src in "$pkg_dir/shell/"*.zsh(N); do
        symlink "$DOTFILES/$src" "$source_dir/${src:t}"
      done
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
  done
}

on_finish() {
  echo
  success "Done — $linked symlinks, $copied files copied, $skipped packages skipped, $failed conflicts."
}

main() {
  on_start
  sync_packages
  on_finish
}

main
