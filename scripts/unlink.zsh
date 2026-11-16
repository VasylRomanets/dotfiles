#!/bin/zsh

# Removes the symlinks dots sync made for the named packages, the opposite of
# syncing them. Only a link that points at the package's own file in this repo
# is touched; a regular file, or a link to somewhere else, is left alone.
#
# Files a package copies (copy/) are not links and stay as they are, and so do
# the links hooks make at runtime, like bat's current.tmTheme.
#
# USAGE: unlink.zsh [OPTIONS] PACKAGE... — run it with --help for the full list

SCRIPTS_PATH="${0:A:h}"
DOTFILES="${SCRIPTS_PATH:h}"

source "$SCRIPTS_PATH/_lib.zsh"

verbose=0
dry_run=0
packages=()
unlinked=0
left=0
dots_config="${XDG_CONFIG_HOME:-$HOME/.config}/dots/config.toml"

usage() {
  cat <<'EOF'
Remove the symlinks that dots sync made for the named packages

Usage:
  unlink.zsh [OPTIONS] PACKAGE...

Options:
  -v, --verbose  Also list the links that aren't in place
  -n, --dry-run  Only print what would change
  -h, --help     Print help
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h | --help)
      usage
      exit 0
      ;;
    -v | --verbose) verbose=1 ;;
    -n | --dry-run) dry_run=1 ;;
    -*)
      error "unlink: unknown option '$arg'"
      exit 1
      ;;
    *) packages+=("$arg") ;;
  esac
done

# Fails unless every name is a package of the repo.
check_packages() {
  local all=("$DOTFILES"/packages/*(/:t)) name
  if (( ! ${#packages} )); then
    error "unlink: name the packages to unlink, e.g. dots unlink git ssh"
    exit 1
  fi
  for name in "${packages[@]}"; do
    (( ${all[(Ie)$name]} )) || {
      error "No package named '$name'. Available: ${(j:, :)all}"
      exit 1
    }
  done
}

# Unlinks $2 if it is a link to the repo file $1.
unlink_one() {
  local src="$1" dest="$2" shown="${2/#$HOME/~}"
  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    (( verbose )) && echo "  [=] $shown (not linked)"
    return
  fi
  if [[ ! -L "$dest" || "${dest:A}" != "${src:A}" ]]; then
    echo "  ! $shown (left, not a link to the repo)"
    (( ++left ))
    return
  fi
  (( dry_run )) || rm "$dest"
  (( ++pkg_changed ))
  (( ++unlinked ))
  echo "  [-] $shown (removed)"
}

# Tells the user how to stop dots sync from linking the package again.
remind_deny() {
  local pkg="$1" denied=""
  [[ -f "$dots_config" ]] && denied="$(toml2json "$dots_config" | jq -r --arg p "$pkg" '(.deny // []) | index($p) // empty')"
  [[ -n "$denied" ]] || echo "To keep dots sync from linking $pkg again, add it to deny in ${dots_config/#$HOME/~}."
}

main() {
  require_macos
  require_commands toml2json jq
  check_packages
  if (( dry_run )); then
    echo "Checking what unlinking dotfiles would change..."
  else
    echo "Unlinking dotfiles..."
  fi

  local pkg src dest
  for pkg in "${packages[@]}"; do
    echo
    echo "Unlinking $pkg..."
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
    elif (( dry_run )); then
      echo "Would remove $pkg_changed of $pkg_total $noun."
    else
      echo "Removed $pkg_changed of $pkg_total $noun."
    fi
    (( dry_run )) || remind_deny "$pkg"
  done

  local summary="Done — links removed: $unlinked, files left alone: $left."
  (( dry_run )) && summary="Dry run, nothing changed — links removed: $unlinked, files left alone: $left."
  echo
  success "$summary"
}

main
