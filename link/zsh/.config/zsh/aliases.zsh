# git
alias g="git"

# grep & ripgrep
alias grep="grep --color=auto"
alias rg="rg --smart-case"

# eza
alias ls="eza --color=always --group-directories-first --icons"
alias ll="eza --color=always --group-directories-first --icons --long --git"
alias la="eza --color=always --group-directories-first --icons --long --git --all"
alias tree="eza --color=always --group-directories-first --icons --tree --level=2"

# fuzzy man page search
alias fman="print -l ${(k)commands} | fzf | xargs man"

# trash
alias rms="trash"

# fortune & cowsay
alias moo="fortune | cowsay --random --rainbow --aurora"
