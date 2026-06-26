#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

stowed=0
shell_linked=0
failed=0
copied=0

# extract a quoted string value from a TOML section: toml_get <file> <section> <key>
toml_get() {
  local file="$1" section="$2" key="$3"
  awk -v s="$section" -v k="$key" '
    /^\[/ { found = ($0 == "[" s "]") }
    found && $0 ~ "^" k "[ \t]*=" {
      gsub(/^[^"]*"|"[[:space:]]*$/, "")
      print
      exit
    }
  ' "$file"
}

cd "$DOTFILES"

for pkg_dir in packages/*/; do
  pkg="$(basename "$pkg_dir")"
  manifest="$pkg_dir/package.toml"

  if [[ -d "$pkg_dir/link" ]]; then
    link_target="$(toml_get "$manifest" link target)"
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
    shell_target="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/packages/$pkg"
    mkdir -p "$shell_target"
    if stow --dir="$pkg_dir" --target="$shell_target" shell; then
      print "linked shell/$pkg"
      (( shell_linked++ ))
    else
      print "warning: failed to link shell/$pkg"
      (( failed++ ))
    fi
  fi

  if [[ -d "$pkg_dir/copy" ]]; then
    copy_target="$(toml_get "$manifest" copy target)"
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
print "done: $stowed stowed, $shell_linked shell-linked, $copied copied, $failed failed"
