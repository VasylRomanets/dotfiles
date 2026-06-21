###############################################################################
# Shell Environment                                                           #
###############################################################################

# nano has odd shortcuts, vim has odd everything, micro is just right
export EDITOR="micro"
export VISUAL="$EDITOR"

# use bat to display and format terminal manual (man) pages
export MANPAGER="sh -c 'col -bx | bat --language=man --plain'"

# interactive pager (less) configs:
# print directly if content fits on one screen
# don't clear the screen when opening/closing
# case-insensitive search unless pattern contains uppercase
# render ANSI colors correctly (e.g. in git output)
# no bell sound at end of file
export LESS='--quit-if-one-screen --no-init --ignore-case --RAW-CONTROL-CHARS --quiet'

# disable history file — search patterns don't need to persist
export LESSHISTFILE='-'

# opt out of Homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# dump a brewfile straight to my dotfiles repo
export HOMEBREW_BUNDLE_FILE="$DOTFILES_SETUP_HOME/Brewfile"

# a secret loaded from macOS Keychain;
# it's used in $CLAUDE_CONFIG_DIR/.claude.json to avoid hardcoding it as plaintext;
# to add it to the Keychain run:
#   security add-generic-password -a "$(whoami)" -s "claude-code-github-mcp-pat" -w "your-token"
export CLAUDE_CODE_GITHUB_MCP_PAT=$(security find-generic-password -a "$(whoami)" -s "claude-code-github-mcp-pat" -w 2>/dev/null)

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
# Zsh Configs (Pre-Plugins)                                                   #
###############################################################################

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/eza.zsh"
source "$ZDOTDIR/ghostty.zsh"
source "$ZDOTDIR/options.zsh"

# must be sourced before zsh-syntax-highlighting
source "$ZDOTDIR/highlight.zsh"

###############################################################################
# Plugins Management                                                          #
###############################################################################

# safely source a brew-installed zsh plugin by name
source_brew_plugin() {
  [[ -x "$HOMEBREW_PREFIX/bin/brew" ]] || return 1
  local plugin_path="$HOMEBREW_PREFIX/share/$1/$1.zsh"
  [[ -r "$plugin_path" ]] && source "$plugin_path"
}

source_brew_plugin zsh-autosuggestions
source_brew_plugin zsh-syntax-highlighting
source_brew_plugin zsh-history-substring-search

unset -f source_brew_plugin

# fzf generates its integration script dynamically via CLI; source_brew_plugin
# expects a static file under $HOMEBREW_PREFIX/share/ and would silently no-op;
# also, 'source <()' (not eval) is required: the script uses 'return' and
# '{ } always { }' (try/finally) which only behave correctly when sourced as a file
source <(fzf --zsh)

###############################################################################
# Zsh Configs (Post-Plugins)                                                  #
###############################################################################

# must be sourced after plugins — calls compinit
source "$ZDOTDIR/completions.zsh"

###############################################################################
# Keybindings                                                                 #
###############################################################################

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

###############################################################################
# Starship                                                                    #
###############################################################################

eval "$(starship init zsh)"

###############################################################################
# Startup                                                                     #
###############################################################################

fastfetch
