#!/bin/zsh

# Bootstrap script for setting up a fresh Mac.
# Based on https://github.com/denysdovhan/dotfiles/blob/master/scripts/bootstrap.sh

set -e
trap on_error ERR

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
TMP_BREWFILE=""
TMP_MAS_BREWFILE=""

source "$SETUP_PATH/_lib.zsh"

cleanup() {
  [[ -n "$TMP_BREWFILE" ]] && rm -f "$TMP_BREWFILE" || true
  [[ -n "$TMP_MAS_BREWFILE" ]] && rm -f "$TMP_MAS_BREWFILE" || true
}

on_error() {
  cleanup
  echo
  error "Bootstrap failed — check the output above."
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
  require_macos
  echo "This script will set up your Mac from scratch:"
  echo "  · Install Xcode Command Line Tools"
  echo "  · Install Homebrew"
  echo "  · Install formulae, casks and App Store apps from Brewfile"
  echo "  · Symlink dotfiles and copy assets"
  echo "  · Configure Git and SSH"
  echo "  · Apply macOS defaults"
  echo
  echo "You'll be prompted before each step."
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping bootstrap."
    echo
    info "No rush — come back anytime!"
    echo
    print_nyan
    exit 0
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

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    error "Homebrew not found after installation — something went wrong."
  fi
}

install_homebrew_packages() {
  info "Step 3 - Install Homebrew packages"
  echo

  if ! _exists brew; then
    echo "Homebrew not installed — skipping."
    echo
    return
  fi

  warning "Review the Brewfile and comment out anything you don't need:"
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

  TMP_BREWFILE="$(mktemp /private/tmp/Brewfile.XXXXXX)"
  grep -E '^(tap |brew |cask |vscode )' "$SETUP_PATH/Brewfile" >> "$TMP_BREWFILE" || true

  echo "Installing Homebrew packages..."
  brew bundle --file="$TMP_BREWFILE"
  rm -f "$TMP_BREWFILE"
  TMP_BREWFILE=""
  success "Homebrew packages installed."
  echo
}

install_mas_apps() {
  info "Step 4 - Install App Store apps"
  echo

  if ! _exists brew; then
    echo "Homebrew not installed — skipping."
    echo
    return
  fi

  if ! grep -qE '^mas ' "$SETUP_PATH/Brewfile"; then
    echo "No App Store apps in Brewfile — skipping."
    echo
    return
  fi

  if ! _exists mas; then
    echo "mas not installed — skipping."
    echo
    return
  fi

  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping App Store apps installation."
    echo
    return
  }
  echo
  echo

  warning "Make sure you're signed into the App Store before proceeding."
  open "macappstore://showAccountPage"
  read -q "?Signed in? [y/N] " || {
    echo
    echo "Skipping App Store apps installation."
    echo
    return
  }
  echo
  echo

  TMP_MAS_BREWFILE="$(mktemp /private/tmp/Brewfile.mas.XXXXXX)"
  grep -E '^(tap |mas )' "$SETUP_PATH/Brewfile" >> "$TMP_MAS_BREWFILE" || true

  echo "Installing App Store apps..."
  brew bundle --file="$TMP_MAS_BREWFILE"
  rm -f "$TMP_MAS_BREWFILE"
  TMP_MAS_BREWFILE=""
  success "App Store apps installed."
  echo
}

sync_dotfiles() {
  info "Step 5 - Symlink dotfiles and copy assets"
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

configure_git() {
  info "Step 6 - Configure Git"
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping Git config."
    echo
    return
  }
  echo
  echo

  local git_config="$HOME/.config/git/config.local"

  if [[ -f "$git_config" ]]; then
    read -q "?$git_config already exists — overwrite? [y/N] " || {
      echo
      echo "Skipping Git config."
      echo
      return
    }
    echo
    echo
    rm -f "$git_config"
  fi

  echo "Git identity — used for commits."
  read "git_name?  Full name:  "
  read "git_email?  Email:      "
  echo

  if [[ -n "$git_name" && -n "$git_email" ]]; then
    mkdir -p "$(dirname "$git_config")"
    cat > "$git_config" <<EOF
[user]
    name = $git_name
    email = $git_email
EOF
    success "Created $git_config"
    echo
  else
    echo "No input — skipping Git config."
    echo
  fi
}

configure_ssh() {
  info "Step 7 - Configure SSH"
  echo
  read -q "?Proceed? [y/N] " || {
    echo
    echo "Skipping SSH config."
    echo
    return
  }
  echo
  echo

  local ssh_config="$HOME/.ssh/config.local"

  if [[ -f "$ssh_config" ]]; then
    read -q "?$ssh_config already exists — overwrite? [y/N] " || {
      echo
      echo "Skipping SSH config."
      echo
      return
    }
    echo
    echo
    rm -f "$ssh_config"
  fi

  echo "SSH config — used for GitHub and other hosts."
  read "ssh_key?  Key path [~/.ssh/id_ed25519]:  "
  ssh_key="${ssh_key:-~/.ssh/id_ed25519}"
  echo

  mkdir -p "$HOME/.ssh"
  cat > "$ssh_config" <<EOF
Host github.com
  IdentityFile $ssh_key
EOF
  success "Created $ssh_config"
  echo
}

apply_macos_defaults() {
  info "Step 8 - Apply macOS defaults"
  echo
  warning "Review macos.zsh and comment out anything you don't need:"
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
  cleanup
  info "Bootstrap complete — happy coding!"
  info "P.S.: Don't forget to restart your terminal."
  echo
  print_nyan
}

main() {
  on_start
  install_xcode_clt
  install_homebrew
  install_homebrew_packages
  install_mas_apps
  sync_dotfiles
  configure_git
  configure_ssh
  apply_macos_defaults
  on_finish
}

main
