# Environment
export PATH="$HOME/.local/bin:$PATH" # prepend ~/.local/bin to the system PATH so user-installed binaries take priority
export EDITOR="micro" # nano has odd shortcuts, vim has odd everything, micro is just right
export VISUAL="$EDITOR"

# Startup
fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of .zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configs
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/diagnostics.zsh"
source "$ZDOTDIR/highlight.zsh" # must be sourced before zsh-syntax-highlighting
source "$ZDOTDIR/options.zsh"

# Plugins

# safely source a Homebrew-installed zsh plugin by name
source_brew_plugin() {
  [[ -x "$HOMEBREW_PREFIX/bin/brew" ]] || return 1
  local plugin_path="$HOMEBREW_PREFIX/share/$1/${2:-$1.zsh}"
  [[ -r "$plugin_path" ]] && source "$plugin_path"
}

source_brew_plugin powerlevel10k powerlevel10k.zsh-theme
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"
source_brew_plugin zsh-autosuggestions
source_brew_plugin zsh-syntax-highlighting
source_brew_plugin zsh-history-substring-search

unset -f source_brew_plugin

# Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
