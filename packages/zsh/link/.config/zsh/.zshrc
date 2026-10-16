# --- Aliases ------------------------------------------------------------------
alias grep="grep --color=auto"

# --- Config -------------------------------------------------------------------
source "$ZDOTDIR/settings.zsh"

# Must precede Packages - some tools (e.g. zoxide) skip registering completions
# if compdef isn't defined yet.
source "$ZDOTDIR/completions.zsh"

# --- Plugins ------------------------------------------------------------------
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# --- Packages -----------------------------------------------------------------
for f in "$ZDOTDIR/source/"*.zsh(N); do
  source "$f"
done
