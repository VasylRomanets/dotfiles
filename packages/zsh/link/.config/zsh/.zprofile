# Homebrew — also belongs in .zprofile rather than .zshrc: its installer
# targets .zprofile for zsh on macOS specifically, and shellenv sets more
# than PATH (MANPATH, INFOPATH, HOMEBREW_*), none of which should be gated
# behind an interactive shell.
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH lives here rather than .zshenv: macOS's path_helper runs after .zshenv
# but before .zprofile, re-prepending system dirs ahead of anything .zshenv
# already exported. Setting it here instead means these actually end up in
# front of the system dirs, as intended.

# prepend ~/.local/bin so user-installed binaries take priority
export PATH="$HOME/.local/bin:$PATH"

# 'cargo install'-ed binaries land in ~/.cargo/bin
export PATH="$HOME/.cargo/bin:$PATH"
