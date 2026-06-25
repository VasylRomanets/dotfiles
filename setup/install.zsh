#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

stowed=0
failed=0
copied=0

cd "$DOTFILES"

for pkg_dir in link/*/; do
  pkg="$(basename "$pkg_dir")"
  if stow "$pkg"; then
    print "stowed $pkg"
    (( stowed++ ))
  else
    print "warning: failed to stow $pkg"
    (( failed++ ))
  fi
done

# copy CotEditor themes — sandboxing prevents symlinks
COTEDIT_THEMES="$HOME/Library/Containers/com.coteditor.CotEditor/Data/Library/Application Support/CotEditor/Themes"
if [[ -d "$DOTFILES/copy/coteditor/themes" ]]; then
  mkdir -p "$COTEDIT_THEMES"
  for theme in "$DOTFILES/copy/coteditor/themes/"*; do
    cp -f "$theme" "$COTEDIT_THEMES/"
    print "copied $(basename "$theme") → CotEditor/Themes"
    (( copied++ ))
  done
fi

print ""
print "done: $stowed stowed, $copied copied, $failed failed"
