#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): points the file fzf-core.zsh sets
# FZF_DEFAULT_OPTS_FILE to at the theme's generated color options — fzf reads
# it fresh on every invocation, no shell-level reactivity needed.
theme=$1

generated_dir="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated"
mkdir -p "$generated_dir"
ln -sf "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/themes/$theme.conf" "$generated_dir/fzf.conf"
