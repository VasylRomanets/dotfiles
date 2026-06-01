# showing my XDG awareness here
# these XDG base directories keep config, state, and cache out of ~/
# also, If I ever want non-default paths, one change propagates everywhere
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# tell zsh where to find .zshrc and other zsh config files
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# where the magic happens (mostly config files)
export DOTFILES_PATH="$HOME/dev/projects/dotfiles"
export DOTFILES_SETUP_PATH="$DOTFILES_PATH/setup"

# locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# print directly if content fits on one screen
# don't clear the screen when opening/closing
# case-insensitive search unless pattern contains uppercase
# render ANSI colors correctly (e.g. in git output)
# no bell sound at end of file
export LESS='--quit-if-one-screen --no-init --ignore-case --RAW-CONTROL-CHARS --quiet'

# disable history file — search patterns don't need to persist
export LESSHISTFILE='-'

export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# initialize Homebrew so its binaries are available in all session types
# (login, interactive, and non-interactive scripts)
# /opt/homebrew is Apple Silicon, /usr/local is Intel Mac
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export HOMEBREW_NO_ANALYTICS=1 # my brew habits are nobody's business
export HOMEBREW_BUNDLE_FILE="$DOTFILES_SETUP_PATH/Brewfile"
