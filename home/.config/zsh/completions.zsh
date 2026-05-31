# initialize the completion system
autoload -Uz compinit

# only rebuild completion cache once per day for faster shell startup
# on macOS, stat uses -f '%Sm' -t '%j' instead of GNU's date -r
ZSH_COMP_DUMP_PATH="$XDG_CACHE_HOME/zsh/zcompdump"
typeset -i updated_at=$(date +'%j' -r "$ZSH_COMP_DUMP_PATH" 2>/dev/null || stat -f '%Sm' -t '%j' "$ZSH_COMP_DUMP_PATH" 2>/dev/null)
if [[ $(date +'%j') != $updated_at ]]; then
  compinit -d "$ZSH_COMP_DUMP_PATH"
else
  compinit -C -d "$ZSH_COMP_DUMP_PATH"
fi

# cache completions for speed (e.g. git branches, brew packages)
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"

# arrow-key navigable completion menu
zstyle ':completion:*' menu select

# group completions by category (files, commands, aliases, etc.)
zstyle ':completion:*' group-name ''

# case and hyphen insensitive matching
# e.g. 'git' matches 'Git', '--no-init' matches '--noinit'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# fuzzy matching — complete even with typos
# allows up to 1 error per 3 characters typed
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# colored output for file completions (uses EZA_COLORS via LS_COLORS fallback)
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# colored messages for completion states
zstyle ':completion:*:*:*:*:corrections'  format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*:*:*:*:messages'     format '%F{magenta}-- %d --%f'
zstyle ':completion:*:*:*:*:warnings'     format '%F{red}-- no matches found --%f'

# complete hidden files (dotfiles) as well
_comp_options+=(globdots)

# don't insert a tab when there's nothing to complete
zstyle ':completion:*' insert-tab pending

# show more context for cd completions
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories

# preferred order for command completions
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# sort files by modification time
zstyle ':completion:*' file-sort modification

# keep the prefix when completing
zstyle ':completion:*' keep-prefix true
