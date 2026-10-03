#!/usr/bin/env zsh

# Reacts to theme-set (see setup/sync.zsh): resolves the slug to Ghostty's
# own display name and applies it. Most slugs match Title Case exactly;
# only the irregular ones need an override.
theme=$1

pretty_name() {
  local slug=$1 word result=""
  # zsh doesn't word-split unquoted expansions like bash does (theme-set's
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
  # title-cased guess, or ghostty-theme would resolve to the built-in.
  kanso-ink | kanso-mist | kanso-pearl | kanso-zen) name="$theme" ;;
  ember | ember-soft | ember-light | everforest-dark-hard | sora | tundra-arctic | tundra-jungle) name="$theme" ;;
  *) name="$(pretty_name "$theme")" ;;
esac

ghostty-theme "$name" >/dev/null
