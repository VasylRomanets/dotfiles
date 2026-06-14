# git
alias g="git"
alias gf="git fetch"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gpu="git pull"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias gst="git stash"

# grep & ripgrep
alias grep="grep --color=auto"
alias rg="rg --smart-case"

# eza
alias ls="eza --color=always --group-directories-first --icons"
alias ll="eza --color=always --group-directories-first --icons --long --git"
alias la="eza --color=always --group-directories-first --icons --long --git --all"
alias tree="eza --color=always --group-directories-first --icons --tree --level=2"

# rm
alias rms="trash"

# Fun
alias moo="fortune | cowsay --random --rainbow --aurora"

joke() {
  curl -s 'https://v2.jokeapi.dev/joke/Programming?type=single' | python3 -c "import sys,json; print(json.load(sys.stdin)['joke'])"
}
