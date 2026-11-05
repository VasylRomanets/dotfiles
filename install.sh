#!/bin/sh

# One-step installer: clones the repo, then runs setup/bootstrap.zsh.
#
#   /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/VasylRomanets/dotfiles/HEAD/install.sh)"
#   curl -fsSL https://raw.githubusercontent.com/VasylRomanets/dotfiles/HEAD/install.sh | sh
#
# Options go to the bootstrap, e.g. `| sh -s -- --yes`. Set DOTFILES_DIR to
# clone somewhere other than ~/.dotfiles.

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

  # When piped into sh, stdin is this script, so the bootstrap's prompts have to
  # read from the terminal. Without one (e.g. CI with --yes), they get no input.
  if (exec </dev/tty) 2>/dev/null; then
    input=/dev/tty
  else
    input=/dev/null
  fi

  /bin/zsh "$dir/setup/bootstrap.zsh" "$@" <"$input"

  # Start a login shell, so PATH and dots work without reopening the terminal.
  if [ "$input" = /dev/tty ]; then
    exec /bin/zsh -l </dev/tty
  fi
}

main "$@"
