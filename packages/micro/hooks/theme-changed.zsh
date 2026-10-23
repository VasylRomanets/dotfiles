#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): repoints the "current" colorscheme
# symlink that settings.json always references, so every micro invocation
# resolves correctly regardless of how micro was launched.
# A colorscheme somebody supplied is named after the slug and wins over the one
# dots build-themes generated, which is named <slug>-generated.
theme=$1

schemes_dir="${XDG_CONFIG_HOME:-$HOME/.config}/micro/colorschemes"
scheme_file="$theme.micro"
[[ -e "$schemes_dir/$scheme_file" ]] || scheme_file="$theme-generated.micro"
ln -sf "$scheme_file" "$schemes_dir/current.micro"
