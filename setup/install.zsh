#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

stowed=0
skipped=0
failed=0
copied=0

toml_get() {
  local file="$1" query="$2"
  [[ -f "$file" ]] || return
  toml2json "$file" | jq -r "$query // empty"
}

cd "$DOTFILES"

for pkg_dir in packages/*/; do
  pkg="$(basename "$pkg_dir")"
  setup="$pkg_dir/setup.toml"

  req_command="$(toml_get "$setup" '.requires.command')"
  req_app="$(toml_get "$setup" '.requires.app')"

  if [[ -n "$req_command" ]] && ! command -v "$req_command" &>/dev/null; then
    print "skipping $pkg — $req_command not found"
    (( skipped++ ))
    continue
  fi

  if [[ -n "$req_app" ]] && \
     [[ ! -d "/Applications/$req_app.app" ]] && \
     [[ ! -d "$HOME/Applications/$req_app.app" ]]; then
    print "skipping $pkg — $req_app not installed"
    (( skipped++ ))
    continue
  fi

  if [[ -d "$pkg_dir/link" ]]; then
    link_target="$(toml_get "$setup" '.link.target')"
    link_target="${${link_target/#\~/$HOME}:-$HOME}"
    if stow --dir="$pkg_dir" --target="$link_target" link; then
      print "stowed $pkg"
      (( stowed++ ))
    else
      print "warning: failed to stow $pkg"
      (( failed++ ))
    fi
  fi

  if [[ -d "$pkg_dir/shell" ]]; then
    shell_target="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/source"
    mkdir -p "$shell_target"
    if stow --dir="$pkg_dir" --target="$shell_target" shell; then
      print "stowed shell/$pkg"
      (( stowed++ ))
    else
      print "warning: failed to stow shell/$pkg"
      (( failed++ ))
    fi
  fi

  if [[ -d "$pkg_dir/copy" ]]; then
    copy_target="$(toml_get "$setup" '.copy.target')"
    copy_target="${copy_target/#\~/$HOME}"
    if [[ -n "$copy_target" ]]; then
      mkdir -p "$copy_target"
      for f in "$pkg_dir/copy/"**/*(.); do
        cp -f "$f" "$copy_target/"
        print "copied $(basename "$f") → $pkg"
        (( copied++ ))
      done
    fi
  fi
done

print ""
print "done: $stowed stowed, $copied copied, $skipped skipped, $failed failed"
