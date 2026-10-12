# Colors live in ~/.config/eza/theme.yml (UI elements) and LS_COLORS (file types)

# On macOS eza reads theme.yml from ~/Library/Application Support/eza, so the
# file linked into ~/.config/eza is ignored and eza uses its default colors
export EZA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eza"

# Aliases
alias ls="eza --color=always --icons=always --group-directories-first"
alias ll="eza --color=always --icons=always --group-directories-first --long --git"
alias la="eza --color=always --icons=always --group-directories-first --long --git --all"
alias tree="eza --color=always --icons=always --group-directories-first --tree --level=2"
