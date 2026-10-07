#!/bin/zsh

# Syncs dotfiles — symlinks packages, sources shell files, copies assets.
#
# With package names, only those are synced. Without, every package is, except
# what the optional config file leaves out (see select_packages).
#
# Every link and copy that changes something is listed (+ new, ~ relinked or
# changed); the ones already in place are left out unless -v is given.
#
# USAGE: sync.zsh [-v] [-n] [package...]
#        -v    also list what is already in place and print the output of successful hooks
#        -n    only report what would change, without linking, copying or running hooks

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

linked=0
skipped=0
failed=0
copied=0
verbose=0
dry_run=0
warnings=()
only=()
selected=()
denied_but_named=()
typeset -A skip_reason

sync_config="${XDG_CONFIG_HOME:-$HOME/.config}/dots/sync.toml"

for arg in "$@"; do
  case "$arg" in
    -v | --verbose) verbose=1 ;;
    -n | --dry-run) dry_run=1 ;;
    -*)
      error "sync: unknown option '$arg'"
      exit 1
      ;;
    *) only+=("$arg") ;;
  esac
done

check_deps() {
  for cmd in toml2json jq; do
    command_exists "$cmd" || {
      error "$cmd not found — run bootstrap.zsh first!"
      exit 1
    }
  done
}

on_start() {
  require_macos
  check_deps
  if (( dry_run )); then
    echo "Checking what syncing dotfiles would change..."
  else
    echo "Syncing dotfiles..."
  fi
}

# Prints a warning and remembers it for the summary at the end.
warn() {
  warning "$*"
  warnings+=("${pkg:+$pkg: }$*")
}

# Counts toward the package's "Linked N of M files." line (pkg_link_ok,
# pkg_link_changed and pkg_link_total, reset for each package) and the totals
# for the final summary. A link that already points at the file is left alone.
symlink() {
  local src="$1" dest="$2" shown="${2/#$HOME/~}" state mark
  (( ++pkg_link_total ))
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    warn "Skipped $shown — already exists and is not a symlink."
    (( ++failed ))
    return
  fi
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    (( ++linked, ++pkg_link_ok ))
    (( verbose )) && echo "  = $shown"
    return
  fi
  if [[ -L "$dest" ]]; then
    state="relinked" mark="~"
  else
    state="new" mark="+"
  fi
  if (( ! dry_run )); then
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest" || {
      warn "Failed to symlink $shown."
      (( ++failed ))
      return
    }
  fi
  (( ++linked, ++pkg_link_ok, ++pkg_link_changed ))
  echo "  $mark $shown ($state)"
}

# Copies the repo file $1 to $2 unless $2 already has the same content.
copy_file() {
  local src="$1" dest="$2" shown="${2/#$HOME/~}" state mark
  (( ++pkg_copy_total ))
  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    (( ++copied, ++pkg_copy_ok ))
    (( verbose )) && echo "  = $shown"
    return
  fi
  if [[ -f "$dest" ]]; then
    state="changed" mark="~"
  else
    state="new" mark="+"
  fi
  if (( ! dry_run )); then
    cp -f "$src" "$dest" || {
      warn "Failed to copy $src."
      (( ++failed ))
      return
    }
  fi
  (( ++copied, ++pkg_copy_ok, ++pkg_copy_changed ))
  echo "  $mark $shown ($state)"
}

# A hook's output is hidden unless it fails (or -v is given), so one noisy
# hook doesn't drown out the rest.
run_hook() {
  local hook="$1" label="$2" output
  [[ -f "$hook" ]] || return
  if (( dry_run )); then
    echo "Would run $label hook."
    return
  fi
  if output="$(zsh "$hook" 2>&1)"; then
    (( verbose )) && [[ -n "$output" ]] && echo "$output"
    echo "Ran $label hook."
  else
    [[ -n "$output" ]] && echo "$output"
    warn "The $label hook failed."
    (( ++failed ))
  fi
}

# Fills `selected` with the packages to go through, in alphabetical order (a
# theme hook may depend on another package having been linked first). A package
# the config file leaves out stays in the list with a `skip_reason`, so it still
# gets a section saying so.
#
# Names on the command line win: they are synced even if the config file leaves
# them out. Otherwise ~/.config/dots/sync.toml may hold lists of package names,
# like the permission lists in Claude Code's settings:
#
#   allow = ["atuin", "bat"]   # sync only these; leave it out to sync all
#   deny = ["ghostty"]         # never sync these; wins over allow
select_packages() {
  local all=("$DOTFILES"/packages/*(/:t)) allow=() deny=() has_allow=false json name
  local forced=()

  for name in "${only[@]}"; do
    (( ${all[(Ie)$name]} )) || {
      echo
      error "No package named '$name'. Available: ${(j:, :)all}"
      exit 1
    }
  done

  if [[ -f "$sync_config" ]]; then
    json="$(toml2json "$sync_config" 2>&1)" || {
      error "Can't read ${sync_config/#$HOME/~}: $json"
      exit 1
    }
    has_allow="$(jq 'has("allow")' <<<"$json")"
    allow=(${(f)"$(jq -r '(.allow // [])[]' <<<"$json")"})
    deny=(${(f)"$(jq -r '(.deny // [])[]' <<<"$json")"})
    for name in "${allow[@]}" "${deny[@]}"; do
      (( ${all[(Ie)$name]} )) || warn "${sync_config/#$HOME/~} lists '$name', which is not a package."
    done
  fi

  for name in "${all[@]}"; do
    if (( ${#only} )); then
      (( ${only[(Ie)$name]} )) || continue
      (( ${deny[(Ie)$name]} )) && forced+=("$name")
    elif (( ${deny[(Ie)$name]} )); then
      skip_reason[$name]="denied in ${sync_config/#$HOME/~}."
    elif [[ "$has_allow" == true ]] && (( ! ${allow[(Ie)$name]} )); then
      skip_reason[$name]="not in the allow list of ${sync_config/#$HOME/~}."
    fi
    selected+=("$name")
  done

  denied_but_named=("${forced[@]}")
}

sync_packages() {
  cd "$DOTFILES"

  local link_verb="Linked" copy_verb="Copied"
  (( dry_run )) && link_verb="Would link" copy_verb="Would copy"

  for pkg in "${selected[@]}"; do
    pkg_dir="packages/$pkg/"
    setup="$pkg_dir/setup.toml"
    echo
    echo "Syncing $pkg..."
    (( ${denied_but_named[(Ie)$pkg]} )) && echo "Denied in ${sync_config/#$HOME/~}, but named here."
    if [[ -n "${skip_reason[$pkg]}" ]]; then
      echo "Skipped — ${skip_reason[$pkg]}"
      still_linked=0
      while IFS=$'\t' read -r src dest; do
        [[ -L "$dest" && "${dest:A}" == "${src:A}" ]] && (( ++still_linked ))
      done < <(package_links "$pkg")
      (( still_linked )) && echo "Its $still_linked link(s) from before are still in place; dots unsync $pkg removes them."
      (( ++skipped ))
      continue
    fi

    req_command="$(toml_get "$setup" '.requires.command')"
    req_app="$(toml_get "$setup" '.requires.app')"

    if [[ -n "$req_command" ]] && ! command_exists "$req_command"; then
      warn "Skipped — $req_command not found."
      (( ++skipped ))
      continue
    fi

    if [[ -n "$req_app" ]] && \
       [[ ! -d "/Applications/$req_app.app" ]] && \
       [[ ! -d "$HOME/Applications/$req_app.app" ]]; then
      warn "Skipped — $req_app not installed."
      (( ++skipped ))
      continue
    fi

    run_hook "$pkg_dir/hooks/pre-setup.zsh" "pre-setup"

    pkg_link_ok=0
    pkg_link_changed=0
    pkg_link_total=0

    while IFS=$'\t' read -r src dest; do
      symlink "$src" "$dest"
    done < <(package_links "$pkg")

    if (( pkg_link_total )); then
      echo "${link_verb} $pkg_link_ok of $pkg_link_total files$( (( pkg_link_changed )) && echo " ($pkg_link_changed changed)")."
    fi

    if [[ -d "$pkg_dir/copy" ]]; then
      copy_target="$(toml_get "$setup" '.copy.target')"
      copy_target="${copy_target/#\~/$HOME}"
      if [[ -n "$copy_target" ]]; then
        (( dry_run )) || mkdir -p "$copy_target"
        pkg_copy_ok=0 pkg_copy_changed=0 pkg_copy_total=0
        for f in "$pkg_dir/copy/"**/*(.N); do
          [[ "${f:t}" == ".DS_Store" ]] && continue
          copy_file "$f" "$copy_target/${f:t}"
        done
        if (( pkg_copy_total )); then
          echo "${copy_verb} $pkg_copy_ok of $pkg_copy_total files$( (( pkg_copy_changed )) && echo " ($pkg_copy_changed changed)")."
        fi
      fi
    fi

    run_hook "$pkg_dir/hooks/post-setup.zsh" "post-setup"
  done
}

ensure_default_theme() {
  # Guarantees a real theme is applied at least once — e.g. micro's
  # settings.json points at "current", a symlink the theme command manages, so
  # without this a fresh machine would show an undefined colorscheme until
  # the theme command is run by hand. Runs after sync_packages (not as a per-package
  # post-setup hook) so every package's hooks.d entry already exists —
  # package processing order is alphabetical, and "theme" sorts before
  # several packages (e.g. yazi) that it needs to have reacted.
  # Idempotent: only acts if no theme has ever been chosen.
  local state_file="${XDG_STATE_HOME:-$HOME/.local/state}/theme/current-theme.txt"
  local theme_cmd="$HOME/.local/bin/theme"
  [[ -s "$state_file" ]] && return
  [[ -x "$theme_cmd" ]] || return
  (( dry_run )) && return
  # A sync of some packages leaves the theme alone unless it includes the theme.
  (( ${#only} && ! ${only[(Ie)theme]} )) && return
  PATH="$HOME/.local/bin:$PATH" "$theme_cmd" rose-pine-moon
}

on_finish() {
  local summary="Done — symlinks: $linked, files copied: $copied, packages skipped: $skipped, problems: $failed."
  (( dry_run )) && summary="Dry run, nothing changed — symlinks: $linked, files copied: $copied, packages skipped: $skipped, problems: $failed."
  echo
  if (( ${#warnings} )); then
    warning "$summary"
    echo
    warning "Warnings:"
    printf '  %s\n' "${warnings[@]}"
  else
    success "$summary"
  fi
}

main() {
  on_start
  select_packages
  sync_packages
  ensure_default_theme
  on_finish
}

main
