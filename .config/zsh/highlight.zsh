typeset -A ZSH_HIGHLIGHT_STYLES

# Everforest Dark Hard
# https://github.com/sainnhe/everforest

# Errors
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#e67e80,bold'

# Commands
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#e67e80'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a7c080,bold'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#a7c080,bold'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#a7c080,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a7c080,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#a7c080,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=#a7c080,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a7c080,italic'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#a7c080'

# Arguments
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#d699b6'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#d699b6'

# Paths
ZSH_HIGHLIGHT_STYLES[path]='fg=#7fbbb3'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#7fbbb3'

# Strings
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#dbbc7f'

# Separators
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#83c092'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#83c092'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#d3c6aa'

# Misc
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#d699b6'
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=#dbbc7f'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#859289'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#d3c6aa'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#d3c6aa'
