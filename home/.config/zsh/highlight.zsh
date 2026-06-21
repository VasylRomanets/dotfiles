unset ZSH_HIGHLIGHT_STYLES
typeset -A ZSH_HIGHLIGHT_STYLES

# Uses ANSI palette colors (1–8) so highlights follow the active terminal theme.
#   1=red  2=green  3=yellow  4=blue  5=magenta  6=cyan  7=white  8=bright-black

# Errors
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=1,bold"

# Commands
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=1"
ZSH_HIGHLIGHT_STYLES[alias]="fg=2,bold"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=2,bold"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=2,bold"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=2,bold"
ZSH_HIGHLIGHT_STYLES[function]="fg=2,bold"
ZSH_HIGHLIGHT_STYLES[command]="fg=2,bold"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=2,italic"
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=2"

# Arguments
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=7"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=7"

# Paths
ZSH_HIGHLIGHT_STYLES[path]="fg=6"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=6"

# Strings
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=3"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=3"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=3"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=3"
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=3"
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=3"
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=3"

# Separators
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=7"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=7"
ZSH_HIGHLIGHT_STYLES[assign]="fg=7"

# Misc
ZSH_HIGHLIGHT_STYLES[globbing]="fg=5"
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=3"
ZSH_HIGHLIGHT_STYLES[comment]="fg=8"
ZSH_HIGHLIGHT_STYLES[named-fd]="fg=7"
ZSH_HIGHLIGHT_STYLES[numeric-fd]="fg=7"
