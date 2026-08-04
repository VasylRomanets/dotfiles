# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Config
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/settings.zsh"
source "$ZDOTDIR/highlight.zsh"
source "$ZDOTDIR/completions.zsh" # must precede Packages - some tools (e.g. zoxide) skip registering completions if compdef isn't defined yet

# Plugins
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  source "$HOMEBREW_PREFIX/share/$plugin/$plugin.zsh"
done

# Packages
for f in "$ZDOTDIR/source/"*.zsh(N); do
  source "$f"
done
