#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): repoints the "current" colorscheme
# symlink that settings.json always references, so every micro invocation
# resolves correctly regardless of how micro was launched.
theme=$1

ln -sf "$theme.micro" "${XDG_CONFIG_HOME:-$HOME/.config}/micro/colorschemes/current.micro"
