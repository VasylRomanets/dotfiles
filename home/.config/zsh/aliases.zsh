# git
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# grep & ripgrep
alias grep="grep --color=auto"
alias rg="rg --smart-case"

# eza
alias ls="eza --icons"
alias ll="eza --icons --long --git"
alias la="eza --icons --long --git --all"
alias tree="eza --tree --icons"

# Fun
alias moo="fortune | cowsay --random --rainbow --aurora"

joke() {
  curl -s 'https://v2.jokeapi.dev/joke/Programming?type=single' | python3 -c "import sys,json; print(json.load(sys.stdin)['joke'])"
}
