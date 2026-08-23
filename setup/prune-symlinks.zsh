#!/bin/zsh

# Finds and removes symlinks anywhere under $HOME that point into this dotfiles repo
# but are now broken — e.g. after a file was renamed or removed.
#
# Not part of `make sync`: a full $HOME scan is unnecessary overhead on every sync,
# so run this occasionally instead, whenever you suspect stale symlinks.

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

pruned=0

prune_orphaned_symlinks() {
  local dest
  # -lname matches a symlink's stored target against a pattern inside `find` itself
  # (no per-file subprocess), so only symlinks pointing into this repo are considered
  # at all — cheap even across all of $HOME. maxdepth is just a sanity cap on
  # recursion depth (no package nests anywhere near this deep), not a scope
  # restriction; it stops `find` wastefully descending into huge trees like
  # ~/Library's app-support caches.
  # Trash contents are already user-deleted; scanning in there would mean silently
  # rm -f'ing things inside the OS trash, bypassing its normal empty-trash flow.
  for dest in "${(@f)$(find "$HOME" -maxdepth 8 -type l \
    -lname "$DOTFILES/*" \
    -not -path "$HOME/.Trash/*" \
    -not -path "$HOME/.local/share/Trash/*" \
    2>/dev/null)}"; do
    [[ -n "$dest" ]] || continue
    # still broken? (leave alone e.g. links into a currently-unmounted drive)
    if [[ ! -e "$dest" ]]; then
      warning "Removing orphaned symlink: $dest"
      rm -f "$dest"
      (( ++pruned ))
    fi
  done
}

main() {
  require_macos
  echo "Scanning \$HOME for orphaned dotfiles symlinks..."
  prune_orphaned_symlinks
  echo
  success "Done — $pruned orphaned symlink(s) removed."
}

main
