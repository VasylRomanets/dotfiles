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

warning() {
  echo "${YELLOW}${*}${RESET}"
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

print_nyan() {
  echo -n "${RED}-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
  echo "${RESET}${BOLD},------,${RESET}"
  echo -n "${YELLOW}-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
  echo "${RESET}${BOLD}|   /\_/\\${RESET}"
  echo -n "${GREEN}-_-_-_-_-_-_-_-_-_-_-_-_-_-"
  echo "${RESET}${BOLD}~|__( ^ .^)${RESET}"
  echo -n "${CYAN}-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
  echo "${RESET}${BOLD}\"\"  \"\"${RESET}"
}

print_logo() {
  echo "${MAGENTA}     _       _    __ _ _         ${RESET}"
  echo "${MAGENTA}  __| | ___ | |_ / _(_) | ___  ___${RESET}"
  echo "${MAGENTA} / _\` |/ _ \\| __| |_| | |/ _ \\/ __|${RESET}"
  echo "${MAGENTA}| (_| | (_) | |_|  _| | |  __/\\__ \\${RESET}"
  echo "${MAGENTA} \\__,_|\\___/ \\__|_| |_|_|\\___||___/${RESET}"
  echo
  echo "${CYAN}         by @vasylromanets${RESET}"
}

on_start() {
  print_logo
  echo
  echo "This script will set up your Mac from scratch:"
  echo "  · Install Xcode Command Line Tools"
  echo "  · Install Homebrew and all packages from Brewfile"
  echo "  · Symlink dotfiles and copy assets"
  echo "  · Set macOS defaults"
  echo
  echo "You'll be prompted before each step."
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo
    info "As you wish! Have a great day!"
    echo
    print_nyan
    exit
  }
  echo
  echo
}

install_xcode_clt() {
  info "Step 1 - Install Xcode Command Line Tools"
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping Xcode Command Line Tools installation."
    echo
    return
  }
  echo
  echo
  echo "Checking Xcode Command Line Tools..."
  if ! xcode-select -p &>/dev/null; then
    echo "Opening installer — click Install in the dialog and wait for it to finish."
    xcode-select --install
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
    success "Xcode Command Line Tools installed."
    echo
  else
    success "Xcode Command Line Tools already installed."
    echo
  fi
}

install_homebrew() {
  info "Step 2 - Install Homebrew"
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping Homebrew installation."
    echo
    return
  }
  echo
  echo
  echo "Checking Homebrew..."
  if ! _exists brew; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew installed."
    echo
  else
    success "Homebrew already installed."
    echo
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_packages() {
  info "Step 3 - Install Homebrew packages"
  echo
  warning "Make sure you reviewed the Brewfile and commented out anything you don't need:"
  echo "  $SETUP_PATH/Brewfile"
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping Homebrew packages installation."
    echo
    return
  }
  echo
  echo
  echo "Installing Homebrew packages..."
  brew bundle --file="$SETUP_PATH/Brewfile"
  success "Packages installed."
  echo
}

sync_dotfiles() {
  info "Step 4 - Symlink dotfiles and copy assets"
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping dotfiles and assets."
    echo
    return
  }
  echo
  echo
  "$SETUP_PATH/sync.zsh"
  echo
}

set_macos_defaults() {
  info "Step 5 - Set macOS defaults"
  echo
  warning "Make sure you reviewed the macos.zsh and commented out anything you don't need:"
  echo "  $SETUP_PATH/macos.zsh"
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping macOS defaults."
    echo
    return
  }
  echo
  echo
  "$SETUP_PATH/macos.zsh"
  echo
}

on_finish() {
  info "Bootstrap complete!"
  info "Don't forget to restart your terminal!"
  info "Happy coding!"
  echo
  print_nyan
}

main() {
  on_start
  install_xcode_clt
  install_homebrew
  install_packages
  sync_dotfiles
  set_macos_defaults
  on_finish
}

main
