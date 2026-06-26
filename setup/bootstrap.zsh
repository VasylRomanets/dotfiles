#!/bin/zsh

set -e # exit on any error

SETUP_PATH="$(dirname "$(realpath "$0")")"

print_step() { echo "\n\033[1;32m==>\033[0m $1"; }
print_info() { echo "    $1"; }

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
if [[ ! -f /opt/homebrew/bin/brew ]]; then
  print_info "installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  print_info "already installed"
fi

# set up Homebrew PATH for this script — .zshrc isn't sourced yet on a fresh machine
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew packages
print_step "Installing Homebrew packages"
brew bundle --file="$SETUP_PATH/Brewfile"

# symlinks and copy
print_step "Creating symlinks and copying files"
"$SETUP_PATH/install.zsh"

print_step "Done! Restart your terminal."
