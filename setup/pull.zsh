#!/bin/zsh

# Pulls the remote changes of this repo. It only fast-forwards and refuses to
# run on a dirty working tree, because the files are linked live into ~ and a
# surprise merge would change the machine's configuration at once.
#
# A pull alone never touches the links: when package files were added, renamed
# or removed it says so and suggests dots sync, or --sync runs it right after.
#
# USAGE: pull.zsh [--sync] [-n]
#        --sync          run dots sync after pulling
#        -n, --dry-run   only fetch and show what would be pulled

SETUP_PATH="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SETUP_PATH")"

source "$SETUP_PATH/_lib.zsh"

run_sync=0
dry_run=0

for arg in "$@"; do
  case "$arg" in
    --sync) run_sync=1 ;;
    -n | --dry-run) dry_run=1 ;;
    *)
      error "pull: unknown argument '$arg'"
      exit 1
      ;;
  esac
done

git_repo() {
  git -C "$DOTFILES" "$@"
}

main() {
  command_exists git || {
    error "git not found — run bootstrap.zsh first!"
    exit 1
  }

  git_repo rev-parse --abbrev-ref '@{u}' &>/dev/null || {
    error "The current branch has no upstream to pull from."
    exit 1
  }

  if [[ -n "$(git_repo status --porcelain --untracked-files=no)" ]]; then
    error "The working tree has uncommitted changes — commit or stash them first."
    exit 1
  fi

  echo "Checking the remote for changes..."
  git_repo fetch --quiet || {
    error "Could not fetch from the remote."
    exit 1
  }

  local old new
  old="$(git_repo rev-parse HEAD)"
  new="$(git_repo rev-parse '@{u}')"

  if [[ "$old" == "$new" ]] || git_repo merge-base --is-ancestor "$new" "$old"; then
    echo
    success "Already up to date."
  else
    git_repo merge-base --is-ancestor "$old" "$new" || {
      error "The local branch has diverged from the remote — merge or rebase it by hand."
      exit 1
    }

    if (( dry_run )); then
      info "Would pull:"
      git_repo log --oneline "$old..$new"
      echo
      git_repo diff --stat "$old" "$new"
      exit 0
    fi

    git_repo merge --ff-only --quiet "$new" || {
      error "Could not fast-forward."
      exit 1
    }
    git_repo log --oneline "$old..HEAD"
    echo
    git_repo diff --stat "$old" HEAD
    success "Pulled $(git_repo rev-list --count "$old..HEAD") commit(s)."
  fi

  (( dry_run )) && exit 0

  if (( run_sync )); then
    echo
    exec "$SETUP_PATH/sync.zsh"
  fi

  # Only a file that appeared, moved or went away can leave a link missing or stale.
  local relinked
  relinked="$(git_repo diff --name-only --diff-filter=ADR "$old" HEAD -- packages setup)"
  if [[ -n "$relinked" ]]; then
    echo
    warning "Package files were added, renamed or removed — run dots sync."
  fi
}

main
