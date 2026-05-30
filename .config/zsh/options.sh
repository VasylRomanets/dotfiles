HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt CORRECT_ALL          # e.g. gti → git
setopt HIST_IGNORE_ALL_DUPS # don't record duplicates
setopt HIST_IGNORE_SPACE    # don't record commands starting with a space
setopt SHARE_HISTORY        # share history across terminal sessions
setopt NO_CASE_GLOB         # e.g. ls *.MD matches ls *.md
