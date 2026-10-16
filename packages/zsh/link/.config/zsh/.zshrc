# --- Aliases ------------------------------------------------------------------
alias grep="grep --color=auto"

# --- History ------------------------------------------------------------------
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=$HISTSIZE

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

# Share history across terminal sessions.
setopt SHARE_HISTORY

# --- Behavior -----------------------------------------------------------------
# Allow # comments in interactive shell.
setopt INTERACTIVE_COMMENTS

# Case-insensitive globbing (e.g. *.MD matches *.md).
setopt NO_CASE_GLOB

# Prevent overwriting files with >.
setopt NO_CLOBBER

# --- Config -------------------------------------------------------------------
# Must precede Packages - some tools (e.g. zoxide) skip registering completions
# if compdef isn't defined yet.
source "$ZDOTDIR/completions.zsh"

# --- Plugins ------------------------------------------------------------------
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# --- Packages -----------------------------------------------------------------
for f in "$ZDOTDIR/source/"*.zsh(N); do
  source "$f"
done
