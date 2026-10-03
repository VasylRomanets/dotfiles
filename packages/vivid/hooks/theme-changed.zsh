#!/usr/bin/env zsh

# Reacts to theme-set (see setup/sync.zsh): renders LS_COLORS for the new theme
# into the file vivid.zsh reads at shell startup, so shells never have to run
# vivid themselves.
theme=$1
vivid_themes_dir="${XDG_CONFIG_HOME:-$HOME/.config}/vivid/themes"
generated_dir="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated"

# Either one of vivid's own bundled themes (when the names happen to match),
# or one of our own custom themes for the ones vivid doesn't ship.
case "$theme" in
  rose-pine | rose-pine-moon | rose-pine-dawn | nord | \
    catppuccin-latte | catppuccin-frappe | catppuccin-macchiato | catppuccin-mocha | \
    tokyonight-night | tokyonight-storm | tokyonight-moon | tokyonight-day)
    vivid_theme="$theme"
    ;;
  *)
    vivid_theme="$vivid_themes_dir/$theme.yml"
    ;;
esac

mkdir -p "$generated_dir"
vivid generate "$vivid_theme" >"$generated_dir/ls_colors"
