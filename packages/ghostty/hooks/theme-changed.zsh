#!/usr/bin/env zsh

# Reacts to theme (see setup/sync.zsh): resolves the slug to Ghostty's
# own display name and applies it. Most slugs match Title Case exactly;
# only the irregular ones need an override, and a local .ghostty file named
# after the slug takes precedence over all of that.
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
  ayu-dark) name="Ayu" ;;
  *) name="$(pretty_name "$theme")" ;;
esac

ghostty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

# A local theme is a file named "<slug>.ghostty" and wins over a built-in of the
# same title-cased name: several of them diverge from it (upstream revised the
# palette after Ghostty vendored it) or have no built-in at all. Built-in themes
# are referenced by name as is.
[[ -e "$ghostty_dir/themes/$theme.ghostty" ]] && name="$theme.ghostty"

# The generated file config.ghostty includes before config.local.ghostty, so
# frequent theme switches stay out of git and out of the hand-written overrides.
generated_dir="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated"
mkdir -p "$generated_dir"
printf 'theme = "%s"\n' "$name" >"$generated_dir/theme.ghostty"

# Ghostty reloads its config on SIGUSR2.
killall -USR2 ghostty 2>/dev/null
exit 0
