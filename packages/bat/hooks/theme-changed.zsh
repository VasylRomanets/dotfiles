#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): repoints the "current.tmTheme"
# symlink that ~/.config/bat/config always references at the active theme,
# then rebuilds bat's cache — bat resolves --theme names from a compiled
# cache rather than reading theme files live, so a plain symlink swap alone
# would leave bat showing whatever was cached at the last rebuild.
theme=$1

themes_dir="${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes"
ln -sf "$theme.tmTheme" "$themes_dir/current.tmTheme"
bat cache --build >/dev/null
