#!/bin/zsh

# Shared utilities sourced by bootstrap.zsh, sync.zsh and macos.zsh.

RESET=$'\033[0m'
BOLD=$'\033[1m'
CYAN=$'\033[0;96m'
MAGENTA=$'\033[0;35m'
RED=$'\033[0;91m'
YELLOW=$'\033[0;93m'
GREEN=$'\033[0;92m'

info() {
  echo "${MAGENTA}${*}${RESET}"
}

warning() {
  echo "${YELLOW}${*}${RESET}"
}

error() {
  echo "${RED}${*}${RESET}"
}

success() {
  echo "${GREEN}${*}${RESET}"
}

require_macos() {
  [[ "$(uname)" == "Darwin" ]] || {
    error "These dotfiles are macOS only!"
    error "Nice try, though."
    exit 1
  }
}

# Prompt for the admin password up front so later privileged steps don't
# stop to ask mid-run. Returns quietly if a sudo session is already active.
request_sudo() {
  sudo -n -v 2>/dev/null && return

  warning "Some steps need admin access — you may be prompted for your password."
  sudo -v || {
    error "Could not obtain admin access."
    exit 1
  }
}

command_exists() {
  command -v "$1" &>/dev/null
}

# Prints a value from a TOML file, e.g. toml_get setup.toml '.requires.command'.
toml_get() {
  local file="$1" query="$2"
  [[ -f "$file" ]] || return
  toml2json "$file" | jq -r "$query // empty"
}

# Prints a tab-separated "<repo file>	<where it is linked>" line for every file
# package $1 links into the machine: its link/ files (into ~, or the target in
# its setup.toml), its source/*.zsh (into zsh's source folder) and its theme
# hook. Needs $DOTFILES, so sync and unsync can't disagree about the targets.
package_links() {
  local pkg="$1" pkg_dir="$DOTFILES/packages/$1" link_target src
  if [[ -d "$pkg_dir/link" ]]; then
    link_target="$(toml_get "$pkg_dir/setup.toml" '.link.target')"
    link_target="${${link_target/#\~/$HOME}:-$HOME}"
    for src in "$pkg_dir/link/"**/*(.DN); do
      [[ "${src:t}" == ".DS_Store" ]] && continue
      print -r -- "$src"$'\t'"$link_target/${src#$pkg_dir/link/}"
    done
  fi
  if [[ -d "$pkg_dir/source" ]]; then
    for src in "$pkg_dir/source/"*.zsh(N); do
      print -r -- "$src"$'\t'"${XDG_CONFIG_HOME:-$HOME/.config}/zsh/source/${src:t}"
    done
  fi
  if [[ -f "$pkg_dir/hooks/theme-changed.zsh" ]]; then
    print -r -- "$pkg_dir/hooks/theme-changed.zsh"$'\t'"${XDG_DATA_HOME:-$HOME/.local/share}/theme/hooks.d/$pkg.zsh"
  fi
}
