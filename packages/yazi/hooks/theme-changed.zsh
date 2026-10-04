#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): a flavor is named after the theme slug
# when its author wrote one, and <slug>-generated when dots build-themes made it
# from the scheme. Yazi only reads theme.toml at startup, so the app:theme action
# (sent to id 0, i.e. every running instance) tells open ones to reload it.
# Yazi picks the dark or light flavor by the terminal's reported background, so
# both are set to the same one to keep the theme applied either way.
theme=$1

yazi_dir="${XDG_CONFIG_HOME:-$HOME/.config}/yazi"

# Checks for the file, not the directory: a flavor renamed in the repo can leave
# an empty directory behind in the config.
flavor="$theme-generated"
[[ -f "$yazi_dir/flavors/$theme.yazi/flavor.toml" ]] && flavor=$theme

printf '[flavor]\ndark = "%s"\nlight = "%s"\n' "$flavor" "$flavor" >"$yazi_dir/theme.toml"
(( $+commands[ya] )) && ya emit-to 0 app:theme >/dev/null 2>&1
