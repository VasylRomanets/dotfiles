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
export DOTFILES_HOME="$HOME/dev/projects/dotfiles"
export DOTFILES_SETUP_HOME="$DOTFILES_HOME/setup"

# locale settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# some app specific configs
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# a secret loaded from macOS Keychain;
# it's used in $CLAUDE_CONFIG_DIR/.claude.json to avoid hardcoding it as plaintext;
# to add it to the Keychain run:
#   security add-generic-password -a "$(whoami)" -s "claude-code-github-mcp-pat" -w "your-token"
export CLAUDE_CODE_GITHUB_MCP_PAT=$(security find-generic-password -a "$(whoami)" -s "claude-code-github-mcp-pat" -w 2>/dev/null)
