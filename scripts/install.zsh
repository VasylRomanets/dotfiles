#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

linked=0
skipped=0

git -C "$DOTFILES" ls-files | while IFS= read -r file; do
  # skip scripts — they belong to the repo, not to ~
  [[ "$file" == scripts/* ]] && continue

  src="$DOTFILES/$file"
  dst="$HOME/$file"

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

print ""
print "done: $linked linked, $skipped skipped"
