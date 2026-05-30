# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Plugins
BREW_PREFIX=$(brew --prefix)
source "$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Configs
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/diagnostics.zsh

# Shell options
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt CORRECT_ALL       # e.g. gti → git
setopt HIST_IGNORE_DUPS  # don't record duplicates
setopt HIST_IGNORE_SPACE # don't record commands starting with a space
setopt SHARE_HISTORY     # share history across terminal sessions

# Environment
export EDITOR="micro"
export VISUAL="$EDITOR"
export PATH="$HOME/.local/bin:$PATH"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
