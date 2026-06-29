#!/bin/zsh

# Demo version of bootstrap.zsh — used to record the README webp.
# Simulates the full bootstrap flow without making any system changes.
#
# To create a webp for GitHub README:
# - brew install ffmpeg-full
# - resize terminal window to ~830x622px before recording
# - open QuickTime (Cmd+Shift+5) and record running this script
# - ffmpeg -i bootstrap.mov -vf "fps=15,scale=830:-1" -loop 0 bootstrap.webp

DEMO_PATH="$(cd "$(dirname "$0")" && pwd)"
source "$DEMO_PATH/../../setup/_lib.zsh"

fake_type() {
  local text="$1"
  for ((i = 1; i <= ${#text}; i++)); do
    echo -n "${text[i]}"
    sleep 0.07
  done
}

proceed() {
  echo -n "Proceed? [y/N] "
  sleep 0.8
  echo "y"
  echo
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

fake_starship_prompt() {
  local dim=$'\033[2;37m'
  local folder=$''
  local branch=$''
  local clock=$''

  local cols
  cols=$(tput cols 2>/dev/null || echo 100)

  # visible left: "╭─ <folder> dotfiles on <branch> main " ≈ 24 cols
  # visible right: " <clock> 12:34" ≈ 8 cols
  local fill_len=$(( cols - 24 - 8 ))
  (( fill_len < 1 )) && fill_len=1
  local fill=""
  repeat $fill_len { fill+="─" }

  printf "${dim}╭─${RESET}"
  printf "${CYAN} ${folder} dotfiles${RESET} "
  printf "${dim}on ${RESET}${MAGENTA}${branch} main${RESET} "
  printf "${dim}${fill} ${clock} 12:34${RESET}\n"
  printf "${dim}╰─${RESET}${GREEN}❯${RESET} "
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

main() {
  # fake_starship_prompt
  # sleep 0.5
  # fake_type "zsh ~/.dotfiles/setup/bootstrap.zsh"
  echo
  sleep 0.3

  print_logo
  echo
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
  sleep 0.8
  proceed

  # Step 1
  info "Step 1 - Install Xcode Command Line Tools"
  echo
  sleep 0.5
  proceed
  echo "Checking Xcode Command Line Tools..."
  sleep 0.5
  success "Xcode Command Line Tools already installed."
  echo

  # Step 2
  info "Step 2 - Install Homebrew"
  echo
  sleep 0.5
  proceed
  echo "Checking Homebrew..."
  sleep 0.5
  success "Homebrew already installed."
  echo

  # Step 3
  info "Step 3 - Install Homebrew packages"
  echo
  warning "Review the Brewfile and comment out anything you don't need:"
  echo "  ~/.dotfiles/setup/Brewfile"
  echo
  sleep 0.5
  proceed
  echo "Installing Homebrew packages..."
  sleep 0.3
  local packages=(bat eza fastfetch fzf git ripgrep starship spinpacks zsh coteditor ghostty)
  for pkg in $packages; do
    echo "Installing $pkg"
    sleep 0.12
  done
  echo
  success "Homebrew Bundle complete! 11 Brewfile dependencies now installed."
  success "Homebrew packages installed."
  echo

  # Step 4
  info "Step 4 - Install App Store apps"
  echo
  sleep 0.5
  proceed
  warning "Make sure you're signed into the App Store before proceeding."
  echo -n "Signed in? [y/N] "
  sleep 0.8
  echo "y"
  echo
  echo "Installing App Store apps..."
  sleep 0.4
  echo "  ==> Downloading Bitwarden (1352778147)"
  sleep 1.0
  echo
  success "App Store apps installed."
  echo

  # Step 5
  info "Step 5 - Symlink dotfiles and copy assets"
  echo
  sleep 0.5
  proceed
  echo "Creating symlinks and copying files..."
  sleep 0.2
  local linked_pkgs=(bat eza fzf git ghostty starship zsh)
  for pkg in $linked_pkgs; do
    success "Linked $pkg"
    sleep 0.1
  done
  success "Copied coteditor"
  echo
  success "Done — 14 symlinks, 1 file copied, 0 skipped, 0 conflicts."
  echo

  # Step 6
  info "Step 6 - Configure Git"
  echo
  sleep 0.5
  proceed
  echo "Git identity — used for commits."
  echo -n "  Full name:  "
  sleep 0.5
  fake_type "Vasyl Romanets"
  echo
  echo -n "  Email:      "
  sleep 0.4
  fake_type "romanets.vasyl@gmail.com"
  echo
  echo
  success "Created ~/.config/git/config.local"
  echo

  # Step 7
  info "Step 7 - Configure SSH"
  echo
  sleep 0.5
  proceed
  echo "SSH config — used for GitHub and other hosts."
  echo -n "  Key path [~/.ssh/id_ed25519]:  "
  sleep 1.0
  echo
  echo
  success "Created ~/.ssh/config.local"
  echo

  # Step 8
  info "Step 8 - Apply macOS defaults"
  echo
  warning "Review macos.zsh and comment out anything you don't need:"
  echo "  ~/.dotfiles/setup/macos.zsh"
  echo
  sleep 0.5
  proceed
  echo "Applying macOS defaults..."
  sleep 1.0
  success "Done — some settings may require a logout or restart to take effect."
  echo

  info "Bootstrap complete — happy coding!"
  info "P.S.: Don't forget to restart your terminal."
  echo
  print_nyan
}

main
