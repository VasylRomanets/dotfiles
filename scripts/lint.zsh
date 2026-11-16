#!/bin/zsh

# Checks the shell scripts of the repo without running them: zsh files are parsed
# with zsh -n, and sh and bash files go through ShellCheck, which doesn't support
# zsh. Without file names it takes every file git tracks (or would track) that is
# a shell script, recognized by its extension (.zsh, .sh) or, for an executable
# file without one, by its shebang.
#
# USAGE: lint.zsh [OPTIONS] [FILE...] — run it with --help for the full list

SCRIPTS_PATH="${0:A:h}"
DOTFILES="${SCRIPTS_PATH:h}"

source "$SCRIPTS_PATH/_lib.zsh"

usage() {
  cat <<'EOF'
Check the shell scripts of the repo for syntax errors and common mistakes

Usage:
  lint.zsh [OPTIONS] [FILE...]

Arguments:
  [FILE...]  Only these files; every shell script of the repo when omitted

Options:
  -h, --help  Print help
EOF
}

files=()
zsh_files=()
sh_files=()
problems=0

for arg in "$@"; do
  case "$arg" in
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      error "lint: unknown option '$arg'"
      exit 1
      ;;
    *) files+=("${arg:A}") ;;
  esac
done

# Sets kind to zsh or sh (bash and the like included) for a shell script, and to
# nothing for any other file. A set variable instead of printed output keeps this
# from starting a process per file.
shell_kind() {
  local file="$1" first
  kind=""
  case "${file:t}" in
    *.zsh | .zshrc | .zshenv | .zprofile | .zlogin)
      kind=zsh
      return
      ;;
    *.sh | *.bash)
      kind=sh
      return
      ;;
  esac
  [[ -x "$file" ]] || return
  IFS= read -r first <"$file" 2>/dev/null
  case "$first" in
    '#!'*zsh*) kind=zsh ;;
    '#!'*/sh | '#!'*' sh' | '#!'*/bash | '#!'*' bash') kind=sh ;;
  esac
}

# Without file names on the command line, every file git knows of, tracked or
# not yet but not ignored, is a candidate.
collect_files() {
  local file
  if (( ${#files} )); then
    for file in "${files[@]}"; do
      [[ -f "$file" ]] || {
        error "lint: no such file '${file/#$PWD\//}'"
        exit 1
      }
    done
    return
  fi
  require_commands git
  while IFS= read -r -d '' file; do
    [[ -f "$DOTFILES/$file" ]] && files+=("$DOTFILES/$file")
  done < <(git -C "$DOTFILES" ls-files -z --cached --others --exclude-standard)
}

sort_files() {
  local file kind
  for file in "${files[@]}"; do
    shell_kind "$file"
    case "$kind" in
      zsh) zsh_files+=("$file") ;;
      sh) sh_files+=("$file") ;;
    esac
  done
}

lint_zsh() {
  local file output
  (( ${#zsh_files} )) || return
  echo "Parsing ${#zsh_files} zsh file(s) with zsh -n..."
  for file in "${zsh_files[@]}"; do
    if ! output="$(zsh -n "$file" 2>&1)"; then
      echo "  ! ${file#$DOTFILES/}"
      print -r -- "$output" | sed 's/^/    /'
      (( ++problems ))
    fi
  done
}

lint_sh() {
  local output
  (( ${#sh_files} )) || return
  echo "Checking ${#sh_files} sh and bash file(s) with ShellCheck..."
  if ! command_exists shellcheck; then
    warning "  shellcheck not found — skipped (brew install shellcheck)."
    return
  fi
  # Run from the repo root so the paths in the report are relative to it.
  if ! output="$(cd "$DOTFILES" && shellcheck -f gcc "${sh_files[@]#$DOTFILES/}" 2>&1)"; then
    print -r -- "$output" | sed 's/^/  /'
    (( problems += ${#${(f)output}} ))
  fi
}

main() {
  require_macos
  collect_files
  sort_files
  if (( ! ${#zsh_files} && ! ${#sh_files} )); then
    echo "No shell scripts to check."
    return
  fi

  lint_zsh
  lint_sh

  echo
  if (( problems )); then
    error "Found $problems problem(s) in ${#zsh_files} zsh and ${#sh_files} sh and bash file(s)."
    exit 1
  fi
  success "Done — ${#zsh_files} zsh and ${#sh_files} sh and bash file(s) checked, no problems."
}

main
