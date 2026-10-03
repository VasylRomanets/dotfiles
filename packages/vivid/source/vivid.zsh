# Open shells keep the colors they started with until restarted.
vivid_ls_colors="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated/ls_colors"
[[ -r $vivid_ls_colors ]] && export LS_COLORS="$(<"$vivid_ls_colors")"
unset vivid_ls_colors
