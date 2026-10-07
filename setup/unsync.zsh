#!/bin/zsh

# Removes the symlinks dots sync made for the named packages, the opposite of
# syncing them. Only a link that points at the package's own file in this repo
# is touched; a regular file, or a link to somewhere else, is left alone. With
# --keep each link is replaced by a copy of the file, so the machine keeps
# working configuration that no longer follows the repo.
#
# Files a package copies (copy/) are not links and stay as they are, and so do
# the links hooks make at runtime, like bat's current.tmTheme.
#
# USAGE: unsync.zsh [--keep] [-v] [-n] <package>...
#        --keep          replace each link with a copy of the file
#        -v              also list the links that aren't in place
#        -n, --dry-run   only print what would change

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

keep=0
verbose=0
dry_run=0
packages=()
unlinked=0
kept=0
left=0
sync_config="${XDG_CONFIG_HOME:-$HOME/.config}/dots/sync.toml"

for arg in "$@"; do
  case "$arg" in
    --keep) keep=1 ;;
    -v | --verbose) verbose=1 ;;
    -n | --dry-run) dry_run=1 ;;
    -*)
      error "unsync: unknown option '$arg'"
      exit 1
      ;;
    *) packages+=("$arg") ;;
  esac
done

check_deps() {
  for cmd in toml2json jq; do
    command_exists "$cmd" || {
      error "$cmd not found — run bootstrap.zsh first!"
      exit 1
    }
  done
}

# Fails unless every name is a package of the repo.
check_packages() {
  local all=("$DOTFILES"/packages/*(/:t)) name
  if (( ! ${#packages} )); then
    error "unsync: name the packages to unsync, e.g. dots unsync git ssh"
    exit 1
  fi
  for name in "${packages[@]}"; do
    (( ${all[(Ie)$name]} )) || {
      error "No package named '$name'. Available: ${(j:, :)all}"
      exit 1
    }
  done
}

# Unlinks (or replaces with a copy) $2 if it is a link to the repo file $1.
unlink_one() {
  local src="$1" dest="$2" shown="${2/#$HOME/~}"
  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    (( verbose )) && echo "  = $shown (not linked)"
    return
  fi
  if [[ ! -L "$dest" || "${dest:A}" != "${src:A}" ]]; then
    echo "  ! $shown (left, not a link to the repo)"
    (( ++left ))
    return
  fi
  if (( ! dry_run && keep )); then
    # Copy beside the link, then rename over it, so a failed copy never leaves
    # the file missing.
    cp -p "$src" "$dest.unsync" && mv -f "$dest.unsync" "$dest"
  elif (( ! dry_run )); then
    rm "$dest"
  fi
  (( ++pkg_changed ))
  if (( keep )); then
    (( ++kept ))
    echo "  ~ $shown (replaced with a copy)"
  else
    (( ++unlinked ))
    echo "  - $shown (removed)"
  fi
}

# Tells the user how to stop dots sync from linking the package again.
remind_deny() {
  local pkg="$1" denied=""
  [[ -f "$sync_config" ]] && denied="$(toml2json "$sync_config" | jq -r --arg p "$pkg" '(.deny // []) | index($p) // empty')"
  [[ -n "$denied" ]] || echo "To keep dots sync from linking $pkg again, add it to deny in ${sync_config/#$HOME/~}."
}

main() {
  require_macos
  check_deps
  check_packages
  if (( dry_run )); then
    echo "Checking what unsyncing dotfiles would change..."
  else
    echo "Unsyncing dotfiles..."
  fi

  local pkg src dest
  for pkg in "${packages[@]}"; do
    echo
    echo "Unsyncing $pkg..."
    pkg_changed=0
    pkg_total=0
    noun="links"
    while IFS=$'\t' read -r src dest; do
      (( ++pkg_total ))
      unlink_one "$src" "$dest"
    done < <(package_links "$pkg")
    (( pkg_total == 1 )) && noun="link"
    if (( pkg_changed == 0 )); then
      echo "Nothing of it is linked."
    elif (( dry_run && keep )); then
      echo "Would replace $pkg_changed of $pkg_total $noun with copies."
    elif (( dry_run )); then
      echo "Would remove $pkg_changed of $pkg_total $noun."
    elif (( keep )); then
      echo "Replaced $pkg_changed of $pkg_total $noun with copies."
    else
      echo "Removed $pkg_changed of $pkg_total $noun."
    fi
    (( dry_run )) || remind_deny "$pkg"
  done

  local summary="Done — links removed: $unlinked, copies kept: $kept, files left alone: $left."
  (( dry_run )) && summary="Dry run, nothing changed — links removed: $unlinked, copies kept: $kept, files left alone: $left."
  echo
  success "$summary"
}

main
