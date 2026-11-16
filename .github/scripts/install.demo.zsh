#!/bin/zsh

# Demo of install.sh — used to record the README webp.
#
# To create a webp for GitHub README:
# - brew install ffmpeg-full
# - resize terminal window to ~830x622px before recording
# - open QuickTime (Cmd+Shift+5) and record running this script
# - ffmpeg -i bootstrap.mov -vf "fps=15,scale=830:-1" -loop 0 bootstrap.webp

DEMO_PATH="$(cd "$(dirname "$0")" && pwd)"
INSTALL_CMD='sh -c "$(curl -fsSL https://raw.githubusercontent.com/vasylromanets/dotfiles/HEAD/install.sh)"'
source "$DEMO_PATH/../../scripts/_lib.zsh"

# Types $1 one character at a time, $2 seconds apart (default 0.07).
fake_type() {
  local text="$1" delay="${2:-0.07}"
  for ((i = 1; i <= ${#text}; i++)); do
    printf "%s" "${text[i]}"
    sleep "$delay"
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

# Mirrors packages/starship/link/.config/starship/starship.toml, with the colors
# starship uses for them (cyan, purple, green and dim).
fake_starship_prompt() {
  local dim=$'\033[2m' cyan=$'\033[36m' purple=$'\033[35m' green=$'\033[32m'
  local branch=$'\uf126'
  local clock=$'\uf017'

  # Like starship, fill the whole width of the terminal. The size comes from the
  # terminal itself, since tput can't see it from inside $(...).
  local cols
  cols=$({ stty size </dev/tty; } 2>/dev/null)
  cols=${cols##* }
  [[ "$cols" == <-> ]] || cols=100

  # Visible left: "╭─ dotfiles on <branch> main " = 22 cols.
  # Visible right: " <clock> HH:MM" = 8 cols.
  local fill_len=$(( cols - 22 - 8 ))
  (( fill_len < 1 )) && fill_len=1
  local fill=""
  repeat $fill_len { fill+="·" }

  printf "${dim}╭─${RESET}"
  printf "${cyan} dotfiles${RESET} "
  printf "${dim}on ${RESET}${purple}${branch} main${RESET} "
  printf "${dim}${fill} ${clock} $(date +%H:%M)${RESET}\n"
  printf "${dim}╰─${RESET}${green}❯${RESET} "
}

# Prints one package's section like sync.zsh does: its first new link and the
# count of all of them.
sync_demo() {
  local pkg="$1" count="$2" file="$3"
  echo
  echo "Syncing $pkg..."
  echo "  [+] ~/$file"
  echo "Linked $count of $count $( (( count == 1 )) && echo file || echo files) ($count changed)."
  sleep 0.1
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
  clear
  # What install.sh prints before it hands over to the bootstrap.
  fake_starship_prompt
  sleep 0.5
  echo "$INSTALL_CMD"
  sleep 0.8
  echo "Cloning into ~/.dotfiles..."
  sleep 1.5
  echo "Cloned ✓"
  echo
  sleep 0.5

  print_logo
  echo
  echo "This script will set up your Mac from scratch:"
  echo "  · Install Xcode Command Line Tools"
  echo "  · Install Homebrew"
  echo "  · Install formulae, casks, cargo crates, and App Store apps from Brewfile"
  echo "  · Symlink dotfiles and copy assets"
  echo "  · Configure SSH and Git"
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
  echo "  ~/.dotfiles/Brewfile"
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
  sync_demo bat 1 .config/bat/config
  sync_demo eza 1 .config/eza/theme.yml
  sync_demo fzf 1 .config/fzf/fzf.zsh
  sync_demo git 3 .config/git/config
  sync_demo ghostty 2 .config/ghostty/config.ghostty
  sync_demo starship 1 .config/starship/starship.toml
  sync_demo zsh 4 .zshenv
  echo
  echo "Syncing coteditor..."
  echo "  [+] ~/Library/Application Support/CotEditor/Themes/Rose Pine Moon.cottheme"
  echo "Copied 1 of 1 file (1 changed)."
  sleep 0.2
  echo
  success "Done — symlinks: 13, files copied: 1, packages skipped: 0, problems: 0."
  echo

  # Step 6
  info "Step 6 - Configure SSH"
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

  # Step 7
  info "Step 7 - Configure Git"
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
  echo "Commit signing — commits and tags are signed with an SSH key."
  echo
  success "Saved ~/.config/git/config.local"
  echo

  # Step 8
  info "Step 8 - Apply macOS defaults"
  echo
  warning "Review macos.zsh and comment out anything you don't need:"
  echo "  ~/.dotfiles/scripts/macos.zsh"
  echo
  sleep 0.5
  proceed
  echo "Applying macOS defaults..."
  sleep 1.0
  success "Done — some settings may require a logout or restart to take effect."
  echo

  info "Bootstrap complete — happy coding!"
  info "P.S. Don't forget to restart your terminal."
  echo
  print_nyan
}

main
