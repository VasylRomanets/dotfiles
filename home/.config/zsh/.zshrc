###############################################################################
# Shell Environment                                                           #
###############################################################################

# prepend ~/.local/bin to the system PATH so user-installed binaries take priority
export PATH="$HOME/.local/bin:$PATH"

# nano has odd shortcuts, vim has odd everything, micro is just right
export EDITOR="micro"
export VISUAL="$EDITOR"

# interactive pager (less) configs:
# print directly if content fits on one screen
# don't clear the screen when opening/closing
# case-insensitive search unless pattern contains uppercase
# render ANSI colors correctly (e.g. in git output)
# no bell sound at end of file
export LESS='--quit-if-one-screen --no-init --ignore-case --RAW-CONTROL-CHARS --quiet'

# disable history file — search patterns don't need to persist
export LESSHISTFILE='-'

# my brew habits are nobody's business
export HOMEBREW_NO_ANALYTICS=1

# dump a brewfile straight to my dotfiles repo
export HOMEBREW_BUNDLE_FILE="$DOTFILES_SETUP_HOME/Brewfile"

###############################################################################
# Initialize Homebrew                                                         #
###############################################################################

# HOMEBREW_PREFIX is set here
# also brew prepends its path to the front of PATH,
# ensuring brew > local bin > system paths
# /opt/homebrew/bin is Apple Silicon, /usr/local/bin is Intel Mac
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

###############################################################################
# Startup                                                                     #
###############################################################################

fastfetch

###############################################################################
# Initialize Powerlevel10k Instant Prompt                                     #
###############################################################################

# should stay close to the top of .zshrc
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

###############################################################################
# Zsh Configs                                                                 #
###############################################################################

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/diagnostics.zsh"
source "$ZDOTDIR/eza.zsh"
source "$ZDOTDIR/options.zsh"
source "$ZDOTDIR/keybindings.zsh"

# must be sourced before zsh-syntax-highlighting
source "$ZDOTDIR/highlight.zsh"

###############################################################################
# Plugins Management                                                          #
###############################################################################

# safely source a brew-installed zsh plugin by name
source_brew_plugin() {
  [[ -x "$HOMEBREW_PREFIX/bin/brew" ]] || return 1
  local plugin_path="$HOMEBREW_PREFIX/share/$1/${2:-$1.zsh}"
  [[ -r "$plugin_path" ]] && source "$plugin_path"
}

source_brew_plugin zsh-autosuggestions
source_brew_plugin zsh-syntax-highlighting
source_brew_plugin zsh-history-substring-search
source_brew_plugin powerlevel10k powerlevel10k.zsh-theme
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"

unset -f source_brew_plugin

# must be sourced after plugins — calls compinit
source "$ZDOTDIR/completions.zsh"
