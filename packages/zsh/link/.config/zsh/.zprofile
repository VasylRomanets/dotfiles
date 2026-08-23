# PATH lives here rather than .zshenv: macOS's path_helper runs after .zshenv
# but before .zprofile, re-prepending system dirs ahead of anything .zshenv
# already exported. Setting it here instead means these actually end up in
# front of the system dirs, as intended.

# prepend ~/.local/bin so user-installed binaries take priority
export PATH="$HOME/.local/bin:$PATH"

# 'cargo install'-ed binaries land in ~/.cargo/bin
export PATH="$HOME/.cargo/bin:$PATH"
