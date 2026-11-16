#!/bin/zsh

# Finds and removes symlinks anywhere under $HOME that point into this dotfiles repo
# but are now broken — e.g. after a file was renamed or removed.
#
# Not part of `dots sync`: a full $HOME scan is unnecessary overhead on every sync,
# so run this occasionally instead, whenever you suspect stale symlinks.
#
# USAGE: prune-symlinks.zsh [-n]
#        -n, --dry-run   only list the symlinks that would be removed

SCRIPTS_PATH="${0:A:h}"
DOTFILES="${SCRIPTS_PATH:h}"

source "$SCRIPTS_PATH/_lib.zsh"

pruned=0
dry_run=0

usage() {
  cat <<'EOF'
Remove broken symlinks under $HOME that point into this repo

Usage:
  prune-symlinks.zsh [OPTIONS]

Options:
  -n, --dry-run  Only list the symlinks that would be removed
  -h, --help     Print help
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h | --help)
      usage
      exit 0
      ;;
    -n | --dry-run) dry_run=1 ;;
    *)
      error "prune-symlinks: unknown argument '$arg'"
      exit 1
      ;;
  esac
done

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
    # Still broken? (leave alone e.g. links into a currently-unmounted drive).
    if [[ ! -e "$dest" ]]; then
      if (( dry_run )); then
        echo "Would remove orphaned symlink: $dest"
      else
        echo "Removing orphaned symlink: $dest"
        rm -f "$dest"
      fi
      (( ++pruned ))
    fi
  done
}

main() {
  require_macos
  echo "Scanning \$HOME for orphaned dotfiles symlinks..."
  prune_orphaned_symlinks
  echo
  if (( dry_run )); then
    success "Dry run, nothing changed — $pruned orphaned symlink(s) to remove."
  else
    success "Done — $pruned orphaned symlink(s) removed."
  fi
}

main
