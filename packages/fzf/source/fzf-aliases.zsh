# Fuzzy man page search.
alias fman="print -l ${(k)commands} | fzf | xargs man"
