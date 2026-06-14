#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

linked=0
skipped=0
copied=0

# symlink everything in home/ to ~/
git -C "$DOTFILES" ls-files home/ | while IFS= read -r file; do
  # strip the leading home/ prefix to get the destination path
  dst="$HOME/${file#home/}"
  src="$DOTFILES/$file"

  mkdir -p "$(dirname "$dst")"

  # warn if destination exists and is a real file (not already a symlink)
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    print "warning: $dst exists and is not a symlink, skipping"
    (( skipped++ ))
    continue
  fi

  ln -sf "$src" "$dst"
  print "linked $dst"
  (( linked++ ))
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
print "done: $linked linked, $copied copied, $skipped skipped"
