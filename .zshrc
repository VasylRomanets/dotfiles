# Environment
export PATH="$HOME/.local/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export EDITOR="micro"
export VISUAL="$EDITOR"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Plugins
BREW_PREFIX=$(brew --prefix)
source "$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Configs
ZSH_CONFIG_HOME="$XDG_CONFIG_HOME/zsh"
source "$ZSH_CONFIG_HOME/aliases.zsh"
source "$ZSH_CONFIG_HOME/diagnostics.zsh"
source "$ZSH_CONFIG_HOME/options.zsh"

# Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
