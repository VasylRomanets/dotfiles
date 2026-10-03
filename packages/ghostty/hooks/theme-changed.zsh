#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): resolves the slug to Ghostty's
# own display name and applies it. Most slugs match Title Case exactly;
# only the irregular ones need an override.
theme=$1

pretty_name() {
  local slug=$1 word result=""
  # zsh doesn't word-split unquoted expansions like bash does (the theme command's
  # own bash version of this relies on that split) — use zsh's own (s:-:)
  # split and (C) capitalize flags instead.
  for word in "${(s:-:)slug}"; do
    result="$result${result:+ }${(C)word}"
  done
  printf '%s' "$result"
}

case "$theme" in
  tokyonight-night) name="TokyoNight" ;;
  tokyonight-storm) name="TokyoNight Storm" ;;
  tokyonight-moon) name="TokyoNight Moon" ;;
  tokyonight-day) name="TokyoNight Day" ;;
  # Local .ghostty files, referenced by their lowercase filename stem.
  # These local files diverge from a same-named Ghostty built-in (upstream
  # revised the palette after Ghostty vendored it), so the slug itself
  # (which the local filename matches) must be passed, not pretty_name's
  # title-cased guess, or Ghostty would load the built-in.
  kanso-ink | kanso-mist | kanso-pearl | kanso-zen) name="$theme" ;;
  ember | ember-soft | ember-light | everforest-dark-hard | sora | tundra-arctic | tundra-jungle) name="$theme" ;;
  *) name="$(pretty_name "$theme")" ;;
esac

ghostty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

# Local themes are files named "<name>.ghostty"; built-in ones are referenced
# by name as is.
[[ -e "$ghostty_dir/themes/$name.ghostty" ]] && name="$name.ghostty"

# The untracked override file config.ghostty includes, which keeps frequent
# theme switches out of git. Resolved first so the in-place edit below doesn't
# replace a symlink with a regular file.
config="$ghostty_dir/config.local.ghostty"
touch "$config"
config="$(realpath "$config")"

if grep -q '^theme = ' "$config"; then
  perl -i -pe "s/^theme = .*/theme = \"$name\"/" "$config"
else
  printf 'theme = "%s"\n' "$name" >>"$config"
fi

# Ghostty reloads its config on SIGUSR2.
killall -USR2 ghostty 2>/dev/null
exit 0
