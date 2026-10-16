#!/usr/bin/env zsh

# Zsh writes the history file and the completion dump but not the directories
# above them, so create those here once instead of on every shell start.
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
