# Environment
export PATH="$HOME/.local/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR="micro"
export VISUAL="$EDITOR"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configs
ZSH_CONFIG_HOME="$XDG_CONFIG_HOME/zsh"
source "$ZSH_CONFIG_HOME/aliases.zsh"
source "$ZSH_CONFIG_HOME/diagnostics.zsh"
source "$ZSH_CONFIG_HOME/highlight.zsh" # must be sourced before zsh-syntax-highlighting
source "$ZSH_CONFIG_HOME/options.zsh"

# Plugins
BREW_PREFIX=$(brew --prefix)

# safely source a Homebrew-installed zsh plugin by name
source_brew_plugin() {
  [[ -x "$BREW_PREFIX/bin/brew" ]] || return 1
  local plugin_path="$BREW_PREFIX/share/$1/${2:-$1.zsh}"
  [[ -r "$plugin_path" ]] && source "$plugin_path"
}

source_brew_plugin powerlevel10k powerlevel10k.zsh-theme
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"
source_brew_plugin zsh-autosuggestions
source_brew_plugin zsh-syntax-highlighting
source_brew_plugin zsh-history-substring-search

unset -f source_brew_plugin

# Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
