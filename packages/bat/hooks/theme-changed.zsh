#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): repoints the "current.tmTheme"
# symlink that ~/.config/bat/config always references at the active theme,
# then rebuilds bat's cache — bat resolves --theme names from a compiled
# cache rather than reading theme files live, so a plain symlink swap alone
# would leave bat showing whatever was cached at the last rebuild.
# A theme file somebody supplied is named after the slug and wins over the one
# dots build-themes generated, which is named <slug>-generated.
theme=$1

themes_dir="${XDG_CONFIG_HOME:-$HOME/.config}/bat/themes"
theme_file="$theme.tmTheme"
[[ -e "$themes_dir/$theme_file" ]] || theme_file="$theme-generated.tmTheme"
ln -sf "$theme_file" "$themes_dir/current.tmTheme"
bat cache --build >/dev/null
