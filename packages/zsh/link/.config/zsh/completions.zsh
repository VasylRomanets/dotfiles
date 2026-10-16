# Initialize the completion system.
autoload -Uz compinit

# Required for the list-colors zstyle below and for menu-select (menu select)
# to actually do anything - neither is auto-loaded by compinit.
zmodload zsh/complist

# Only rebuild completion cache once per day for faster shell startup. The glob
# matches the dump file only when it is more than 24 hours old (a missing file
# matches nothing, and compinit -C then creates it). The touch is needed because
# compinit leaves an up-to-date dump untouched, so it would stay stale forever.
ZSH_COMP_DUMP_PATH="$XDG_CACHE_HOME/zsh/zcompdump"
stale_dump=($ZSH_COMP_DUMP_PATH(N.mh+24))
if (( $#stale_dump )); then
  compinit -d "$ZSH_COMP_DUMP_PATH"
  touch "$ZSH_COMP_DUMP_PATH"
else
  compinit -C -d "$ZSH_COMP_DUMP_PATH"
fi
unset stale_dump

# Cache completions for speed (e.g. brew packages).
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"

# Arrow-key navigable completion menu.
zstyle ':completion:*' menu select

# Group completions by category (files, commands, aliases, etc.).
zstyle ':completion:*' group-name ''

# Case and hyphen insensitive matching — e.g. 'git' matches 'Git', '--no-init'
# matches '--noinit'.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# Colored output for file completions. Evaluated on each completion (-e) rather
# than once here, since LS_COLORS is only set later by the vivid package.
zstyle -e ':completion:*:default' list-colors 'reply=(${(s.:.)LS_COLORS})'

# Colored messages for completion states.
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*:*:*:*:messages'     format '%F{magenta}-- %d --%f'
zstyle ':completion:*:*:*:*:warnings'     format '%F{red}-- no matches found --%f'

# Complete hidden files (dotfiles) as well.
_comp_options+=(globdots)
