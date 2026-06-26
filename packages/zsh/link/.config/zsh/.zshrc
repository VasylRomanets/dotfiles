# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Pre-plugin config
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/settings.zsh"
source "$ZDOTDIR/highlight.zsh" # must precede zsh-syntax-highlighting

# Plugins
for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search; do
  source "$HOMEBREW_PREFIX/share/$plugin/$plugin.zsh"
done

# Post-plugin config
source "$ZDOTDIR/completions.zsh" # must follow plugins — calls compinit

# Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Packages
for f in "$ZDOTDIR/packages/"*/shell.zsh(N); do
  source "$f"
done
