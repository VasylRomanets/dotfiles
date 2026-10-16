#!/usr/bin/env zsh

# Zsh writes the history file but not the directory above it, so create it here
# once instead of on every shell start.
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
