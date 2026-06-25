# XDG base directories — keeps config, state, and cache out of ~/
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# tell Zsh where to find .zshrc
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# prepend ~/.local/bin so user-installed binaries take priority
export PATH="$HOME/.local/bin:$PATH"

# nano has odd shortcuts, vim has odd everything, micro is just right
export EDITOR="micro"
export VISUAL="$EDITOR"

# dotfiles repo paths
export DOTFILES_HOME="$HOME/dev/projects/dotfiles"
export DOTFILES_SETUP_HOME="$DOTFILES_HOME/setup"

# locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# app-specific config paths
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
