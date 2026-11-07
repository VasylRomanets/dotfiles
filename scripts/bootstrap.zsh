#!/bin/zsh

# Bootstrap script for setting up a fresh Mac.
# Based on https://github.com/denysdovhan/dotfiles/blob/master/scripts/bootstrap.sh

set -e
trap on_error ERR

SCRIPTS_PATH="${0:A:h}"
DOTFILES="${SCRIPTS_PATH:h}"
TMP_BREWFILE=""
TMP_MAS_BREWFILE=""
ssh_key=""

source "$SCRIPTS_PATH/_lib.zsh"

usage() {
  cat <<'EOF'
Set up a fresh Mac

Usage:
  bootstrap.zsh [--yes]

Options:
  -y, --yes   Run every step without asking. App Store apps are skipped,
              existing SSH and Git configs are kept, and the SSH key and Git
              identity come from DOTS_SSH_KEY, DOTS_GIT_NAME and DOTS_GIT_EMAIL
              (when unset, SSH uses the default key and the Git config is skipped).
              The same key signs your commits. A missing key is not created.
  -h, --help  Print help
EOF
}

for arg in "$@"; do
  case "$arg" in
    -y | --yes) ASSUME_YES=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      error "Unknown option: $arg"
      usage >&2
      exit 1
      ;;
  esac
done

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
  echo "  · Install formulae, casks, cargo crates, and App Store apps from Brewfile"
  echo "  · Symlink dotfiles and copy assets"
  echo "  · Configure SSH and Git"
  echo "  · Apply macOS defaults"
  echo
  if [[ -n "$ASSUME_YES" ]]; then
    echo "Running with --yes: every step runs without asking."
  else
    echo "You'll be prompted before each step."
  fi
  echo
  confirm || {
    echo "Skipping bootstrap."
    echo
    info "No rush — come back anytime!"
    echo
    print_nyan
    exit 0
  }
}

install_xcode_clt() {
  info "Step 1 - Install Xcode Command Line Tools"
  echo
  confirm || {
    echo "Skipping Xcode Command Line Tools installation."
    echo
    return
  }
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
  confirm || {
    echo "Skipping Homebrew installation."
    echo
    return
  }
  echo "Checking Homebrew..."
  if ! command_exists brew; then
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

  if ! command_exists brew; then
    echo "Homebrew not installed — skipping."
    echo
    return
  fi

  warning "Review the Brewfile and comment out anything you don't need:"
  echo "  $DOTFILES/Brewfile"
  echo
  confirm || {
    echo "Skipping Homebrew packages installation."
    echo
    return
  }

  # Some casks run privileged installers; authenticate now so brew bundle
  # doesn't stop to prompt partway through.
  request_sudo

  TMP_BREWFILE="$(mktemp /private/tmp/Brewfile.XXXXXX)"
  grep -v '^mas ' "$DOTFILES/Brewfile" >> "$TMP_BREWFILE" || true

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

  if ! command_exists brew; then
    echo "Homebrew not installed — skipping."
    echo
    return
  fi

  if ! grep -qE '^mas ' "$DOTFILES/Brewfile"; then
    echo "No App Store apps in Brewfile — skipping."
    echo
    return
  fi

  if ! command_exists mas; then
    echo "mas not installed — skipping."
    echo
    return
  fi

  confirm || {
    echo "Skipping App Store apps installation."
    echo
    return
  }

  warning "Make sure you're signed into the App Store before proceeding."
  open "macappstore://showAccountPage"
  confirm "Signed in?" no || {
    echo "Skipping App Store apps installation."
    echo
    return
  }

  TMP_MAS_BREWFILE="$(mktemp /private/tmp/Brewfile.mas.XXXXXX)"
  grep -E '^mas ' "$DOTFILES/Brewfile" >> "$TMP_MAS_BREWFILE" || true

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
  confirm || {
    echo "Skipping dotfiles and assets."
    echo
    return
  }
  "$SCRIPTS_PATH/sync.zsh"
  echo
}

# Asks for the SSH key once. The SSH config uses its private key and Git
# signs commits with its public key.
ask_ssh_key() {
  [[ -n "$ssh_key" ]] && return
  if [[ -n "$ASSUME_YES" ]]; then
    ssh_key="$DOTS_SSH_KEY"
  else
    read "ssh_key?  Key path [~/.ssh/id_ed25519]:  "
  fi
  ssh_key="${ssh_key:-~/.ssh/id_ed25519}"
}

# Offers to create the key when it doesn't exist yet, then says where to
# register it. ssh-keygen asks for the passphrase itself.
ensure_ssh_key() {
  local key="${ssh_key%.pub}"
  key="${key/#\~/$HOME}"
  [[ -f "$key" || -f "$key.pub" ]] && return

  if [[ -n "$ASSUME_YES" ]]; then
    warning "$ssh_key does not exist — create it with: ssh-keygen -t ed25519 -f $ssh_key"
    return
  fi
  confirm "$ssh_key does not exist — create it now?" no || return

  mkdir -p -m 700 "${key:h}"
  ssh-keygen -t ed25519 -f "$key" || {
    warning "The key was not created."
    return
  }

  echo
  echo "Add this public key to GitHub as both an authentication and a signing key:"
  echo "  $(<"$key.pub")"
  if command_exists gh && gh auth status &>/dev/null; then
    echo "  gh ssh-key add $key.pub --type authentication"
    echo "  gh ssh-key add $key.pub --type signing"
  else
    echo "  https://github.com/settings/keys"
  fi
}

configure_ssh() {
  info "Step 6 - Configure SSH"
  echo
  confirm || {
    echo "Skipping SSH config."
    echo
    return
  }

  local ssh_config="$HOME/.ssh/config.local"

  if [[ -f "$ssh_config" ]]; then
    confirm "$ssh_config already exists — overwrite?" no || {
      echo "Skipping SSH config."
      echo
      return
    }
    rm -f "$ssh_config"
  fi

  echo "SSH config — used for GitHub and other hosts."
  ask_ssh_key
  echo
  ensure_ssh_key

  mkdir -p "$HOME/.ssh"
  cat > "$ssh_config" <<EOF
Host github.com
  IdentityFile ${ssh_key%.pub}
EOF
  success "Created $ssh_config"
  echo
}

configure_git() {
  info "Step 7 - Configure Git"
  echo
  # Without the Command Line Tools, git is a shim that opens an install dialog.
  if ! xcode-select -p &>/dev/null && [[ ! -x /opt/homebrew/bin/git ]]; then
    echo "git is not installed yet — skipping Git config."
    echo
    return
  fi

  confirm || {
    echo "Skipping Git config."
    echo
    return
  }

  local git_config="$HOME/.config/git/config.local"

  if [[ -f "$git_config" ]]; then
    confirm "$git_config already exists — change the name and email in it?" no || {
      echo "Skipping Git config."
      echo
      return
    }
  fi

  echo "Git identity — used for commits."
  if [[ -n "$ASSUME_YES" ]]; then
    git_name="$DOTS_GIT_NAME"
    git_email="$DOTS_GIT_EMAIL"
  else
    read "git_name?  Full name:  "
    read "git_email?  Email:      "
  fi
  echo

  if [[ -n "$git_name" && -n "$git_email" ]]; then
    mkdir -p "${git_config:h}"
    git config --file "$git_config" user.name "$git_name"
    git config --file "$git_config" user.email "$git_email"
    echo "Commit signing — commits and tags are signed with an SSH key."
    ask_ssh_key
    git config --file "$git_config" user.signingKey "${ssh_key%.pub}.pub"
    echo
    success "Saved $git_config"
    echo
  else
    echo "No input — skipping Git config."
    echo
  fi
}

apply_macos_defaults() {
  info "Step 8 - Apply macOS defaults"
  echo
  warning "Review macos.zsh and comment out anything you don't need:"
  echo "  $SCRIPTS_PATH/macos.zsh"
  echo
  confirm || {
    echo "Skipping macOS defaults."
    echo
    return
  }
  "$SCRIPTS_PATH/macos.zsh"
  echo
}

on_finish() {
  cleanup
  info "Bootstrap complete — happy coding!"
  info "P.S. Don't forget to restart your terminal."
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
  configure_ssh
  configure_git
  apply_macos_defaults
  on_finish
}

main
