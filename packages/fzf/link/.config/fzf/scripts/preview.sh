#!/bin/sh

# Previews a path for fzf: a directory as a tree, a binary file as "Binary file",
# and any other file with syntax highlighting. Falls back to find and cat when
# eza or bat is missing.

path=$1

if [ -d "$path" ]; then
  if command -v eza >/dev/null 2>&1; then
    eza --tree --color=always "$path" | head -200
  else
    find "$path" -maxdepth 3 | head -200
  fi
# bat only prints a warning for a binary file. An empty file also reports as
# binary, hence the size check.
elif [ -s "$path" ] && [ "$(file --brief --mime-encoding "$path")" = binary ]; then
  echo "Binary file"
elif command -v bat >/dev/null 2>&1; then
  bat -n --color=always --line-range :500 "$path"
else
  cat "$path"
fi
