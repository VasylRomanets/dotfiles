#!/usr/bin/env zsh

# Reacts to theme-set (see setup/sync.zsh): points delta's include at this
# theme's gitconfig — git re-reads config on every invocation, so nothing
# else needs to happen here.
theme=$1

git_delta_include="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated/delta.gitconfig"
delta_theme_file="${XDG_CONFIG_HOME:-$HOME/.config}/git/delta-themes/$theme.gitconfig"

mkdir -p "${git_delta_include:h}"
cat >"$git_delta_include" <<EOF
[include]
  path = $delta_theme_file
EOF
