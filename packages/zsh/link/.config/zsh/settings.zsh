SPROMPT="Correct '%F{red}%R%f' to '%F{green}%r%f' [nyae]? "

export CORRECT_IGNORE=".*"
export CORRECT_IGNORE_FILE="_*"

ZSH_STATE_HOME="$XDG_STATE_HOME/zsh"

# Ensure directory exists before writing history.
mkdir -p "$ZSH_STATE_HOME"

HISTFILE="$ZSH_STATE_HOME/history"
HISTSIZE=10000
SAVEHIST=$HISTSIZE

# Interactive pager (less) configs:
# Print directly if content fits on one screen.
# Don't clear the screen when opening/closing.
# Case-insensitive search unless pattern contains uppercase.
# Render ANSI colors correctly (e.g. in git output).
# No bell sound at end of file.
export LESS='--quit-if-one-screen --no-init --ignore-case --RAW-CONTROL-CHARS --quiet'

# Disable history file — search patterns don't need to persist.
export LESSHISTFILE='-'

# Prevent duplicate entries.
declare -U PATH

# e.g. gti → git
setopt CORRECT_ALL

# Skip duplicates when searching.
setopt HIST_FIND_NO_DUPS

# Ignore all duplicates, not just consecutive.
setopt HIST_IGNORE_ALL_DUPS

# Ignore commands starting with a space.
setopt HIST_IGNORE_SPACE

# Strip extra whitespace.
setopt HIST_REDUCE_BLANKS

# Preview history expansions before running.
setopt HIST_VERIFY

# Allow # comments in interactive shell.
setopt INTERACTIVE_COMMENTS

# Case-insensitive globbing (e.g. *.MD matches *.md).
setopt NO_CASE_GLOB

# Prevent overwriting files with >.
setopt NO_CLOBBER

# Share history across terminal sessions.
setopt SHARE_HISTORY
