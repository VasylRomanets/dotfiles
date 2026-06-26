# grep
alias grep="grep --color=auto"

# fuzzy man page search
alias fman="print -l ${(k)commands} | fzf | xargs man"
