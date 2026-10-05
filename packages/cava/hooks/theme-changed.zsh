#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): repoints the "current" gradient that
# ~/.config/cava/config always references at the new theme's, then tells a
# running cava to reload its config. SIGUSR1 reloads everything; SIGUSR2 would
# only reload the gradient and leave the old background in place.
theme=$1

ln -sf "$theme" "${XDG_CONFIG_HOME:-$HOME/.config}/cava/themes/current"
pkill -USR1 -x cava 2>/dev/null
exit 0
