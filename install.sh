#!/bin/sh

# One-step installer: clones the repo, then runs scripts/bootstrap.zsh.
#
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/VasylRomanets/dotfiles/HEAD/install.sh)"
#
# Run it this way, not piped into sh, so the prompts can read from the terminal.
# Set DOTFILES_DIR to clone somewhere other than ~/.dotfiles.

set -e

# Everything lives in a function that runs on the last line, so a download that
# stops halfway never runs a partial script.
main() {
  if [ "$(uname)" != "Darwin" ]; then
    echo "These dotfiles are macOS only!" >&2
    exit 1
  fi

  dir="${DOTFILES_DIR:-$HOME/.dotfiles}"

  # On a fresh Mac, git is a shim that needs the Command Line Tools first.
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "Installing Xcode Command Line Tools — click Install in the dialog and wait."
    xcode-select --install >/dev/null 2>&1 || true
    until xcode-select -p >/dev/null 2>&1; do
      sleep 5
    done
  fi

  if [ -d "$dir/.git" ]; then
    echo "Updating $dir..."
    git -C "$dir" pull --ff-only || echo "Could not update $dir — using it as it is."
  else
    git clone https://github.com/VasylRomanets/dotfiles.git "$dir"
  fi

  /bin/zsh "$dir/scripts/bootstrap.zsh"
}

main "$@"
