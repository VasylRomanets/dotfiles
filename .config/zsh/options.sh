ZSH_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}/zsh
mkdir -p "$ZSH_STATE_HOME" # ensure directory exists before writing history

HISTFILE=$ZSH_STATE_HOME/history
HISTSIZE=10000
SAVEHIST=10000

# set the option only if it's supported by current shell version
setopt_if_exists() {
  if [[ "${options[$1]+1}" ]]; then
    setopt "$1"
  fi
}

setopt_if_exists CORRECT_ALL          # e.g. gti → git
setopt_if_exists HIST_FIND_NO_DUPS    # skip duplicates when searching
setopt_if_exists HIST_IGNORE_ALL_DUPS # ignore all duplicates, not just consecutive
setopt_if_exists HIST_IGNORE_SPACE    # ignore commands starting with a space
setopt_if_exists HIST_REDUCE_BLANKS   # strip extra whitespace
setopt_if_exists HIST_VERIFY          # preview history expansions before running
setopt_if_exists INTERACTIVE_COMMENTS # allow # comments in interactive shell
setopt_if_exists NO_CASE_GLOB         # case-insensitive globbing (e.g. *.MD matches *.md)
setopt_if_exists NO_CLOBBER           # prevent overwriting files with >
setopt_if_exists SHARE_HISTORY        # share history across terminal sessions

unset setopt_if_exists # clean up helper function
