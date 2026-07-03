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
