#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): yazi's flavor names are the theme
# slugs. Yazi only reads theme.toml at startup, so the app:theme action (sent to
# id 0, i.e. every running instance) tells open ones to reload it.
# Yazi picks the dark or light flavor by the terminal's reported background, so
# both are set to the same one to keep the theme applied either way.
theme=$1

yazi_theme_file="${XDG_CONFIG_HOME:-$HOME/.config}/yazi/theme.toml"
printf '[flavor]\ndark = "%s"\nlight = "%s"\n' "$theme" "$theme" >"$yazi_theme_file"
(( $+commands[ya] )) && ya emit-to 0 app:theme >/dev/null 2>&1
