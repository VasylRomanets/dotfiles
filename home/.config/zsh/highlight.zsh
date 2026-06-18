unset ZSH_HIGHLIGHT_STYLES
typeset -A ZSH_HIGHLIGHT_STYLES

# Everforest Dark Hard (https://github.com/sainnhe/everforest)
local red='#e67e80'
local orange='#e69875'
local yellow='#dbbc7f'
local green='#a7c080'
local aqua='#83c092'
local blue='#7fbbb3'
local purple='#d699b6'
local white='#d3c6aa'
local grey='#859289'

# Errors
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$red,bold"

# Commands
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$red"
ZSH_HIGHLIGHT_STYLES[alias]="fg=$green,bold"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=$green,bold"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=$green,bold"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=$green,bold"
ZSH_HIGHLIGHT_STYLES[function]="fg=$green,bold"
ZSH_HIGHLIGHT_STYLES[command]="fg=$green,bold"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=$green,italic"
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=$green"

# Arguments
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$white"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$white"

# Paths
ZSH_HIGHLIGHT_STYLES[path]="fg=$aqua"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=$aqua"

# Strings
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$orange"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$orange"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=$orange"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$orange"
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=$orange"
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=$orange"
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=$orange"

# Separators
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$white"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=$white"
ZSH_HIGHLIGHT_STYLES[assign]="fg=$white"

# Misc
ZSH_HIGHLIGHT_STYLES[globbing]="fg=$purple"
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=$yellow"
ZSH_HIGHLIGHT_STYLES[comment]="fg=$grey"
ZSH_HIGHLIGHT_STYLES[named-fd]="fg=$white"
ZSH_HIGHLIGHT_STYLES[numeric-fd]="fg=$white"
