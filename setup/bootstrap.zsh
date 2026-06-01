#!/bin/zsh

set -e # exit on any error

DOTFILES_PATH="$(dirname "$(dirname "$(realpath "$0")")")"
SETUP_PATH="$DOTFILES_PATH/setup"

print_step() { echo "\n\033[1;32m==>\033[0m $1"; }
print_info() { echo "    $1"; }

# macOS only
if [[ "$(uname)" != "Darwin" ]]; then
  echo "error: this script is for macOS only"
  exit 1
fi

# Xcode Command Line Tools
print_step "Checking Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  print_info "opening installer — click Install in the dialog and wait for it to finish"
  xcode-select --install
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  print_info "installed"
else
  print_info "already installed"
fi

# Homebrew
print_step "Checking Homebrew"
if [[ ! -f /opt/homebrew/bin/brew ]] && [[ ! -f /usr/local/bin/brew ]]; then
  print_info "installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  print_info "already installed"
fi

# set up Homebrew PATH for this script — .zshenv isn't sourced yet on a fresh machine
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Homebrew packages
print_step "Installing Homebrew packages"
brew bundle --file="$SETUP_PATH/Brewfile"

# symlinks and copy
print_step "Creating symlinks and copying files"
"$SETUP_PATH/install.zsh"

print_step "Done! Restart your terminal."
