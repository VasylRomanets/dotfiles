#!/bin/zsh

# Bootstrap script for setting up a fresh Mac.
# Based on https://github.com/denysdovhan/dotfiles/blob/master/scripts/bootstrap.sh

set -e
trap on_error ERR

RESET=$'\033[0m'
BOLD=$'\033[1m'
CYAN=$'\033[0;96m'
MAGENTA=$'\033[0;35m'
RED=$'\033[0;91m'
YELLOW=$'\033[0;93m'
GREEN=$'\033[0;92m'

SETUP_PATH="$(dirname "$(realpath "$0")")"

_exists() {
  command -v "$1" &>/dev/null
}

info() {
  echo "${MAGENTA}${*}${RESET}"
}

error() {
  echo "${RED}${*}${RESET}"
}

success() {
  echo "${GREEN}${*}${RESET}"
}

on_error() {
  echo
  error "Bootstrap failed — check the output above."
  echo
  exit 1
}

on_start() {
  echo "${RED}     _       _    __ _ _         ${RESET}"
  echo "${YELLOW}  __| | ___ | |_ / _(_) | ___  ___${RESET}"
  echo "${GREEN} / _\` |/ _ \\| __| |_| | |/ _ \\/ __|${RESET}"
  echo "${CYAN}| (_| | (_) | |_|  _| | |  __/\\__ \\${RESET}"
  echo "${YELLOW} \\__,_|\\___/ \\__|_| |_|_|\\___||___/${RESET}"
  echo
  echo "${GREEN}         by @vasylromanets${RESET}"
  echo
  echo "This script will set up your Mac from scratch."
  echo
  read -q "?Proceed? [y/N] " || { echo; echo "As you wish! Have a great day!"; echo; exit }
  echo
}

install_xcode_clt() {
  info "Checking Xcode Command Line Tools..."
  if ! xcode-select -p &>/dev/null; then
    info "Opening installer — click Install in the dialog and wait for it to finish."
    xcode-select --install
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
    success "Xcode Command Line Tools installed."
  else
    success "Xcode Command Line Tools already installed."
  fi
}

install_homebrew() {
  info "Checking Homebrew..."
  if ! _exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew installed."
  else
    success "Homebrew already installed."
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_packages() {
  info "Installing Homebrew packages..."
  brew bundle --file="$SETUP_PATH/Brewfile"
  success "Packages installed."
}

sync_dotfiles() {
  info "Creating symlinks and copying files..."
  "$SETUP_PATH/install.zsh"
}

on_finish() {
  echo
  success "Bootstrap complete!"
  success "Happy Coding!"
  echo
  echo -n "${RED}-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
  echo "${RESET}${BOLD},------,${RESET}"
  echo -n "${YELLOW}-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
  echo "${RESET}${BOLD}|   /\_/\\${RESET}"
  echo -n "${GREEN}-_-_-_-_-_-_-_-_-_-_-_-_-_-"
  echo "${RESET}${BOLD}~|__( ^ .^)${RESET}"
  echo -n "${CYAN}-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
  echo "${RESET}${BOLD}\"\"  \"\"${RESET}"
  echo
  info "P.S.: Don't forget to restart your terminal!"
  echo
}

main() {
  on_start
  install_xcode_clt
  install_homebrew
  install_packages
  sync_dotfiles
  on_finish
}

main
