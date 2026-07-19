fzf_rose_pine="
  --color=fg:#908caa,bg:#191724,hl:#ebbcba
  --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
  --color=border:#403d52,header:#31748f,gutter:#191724
  --color=spinner:#f6c177,info:#9ccfd8
  --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

fzf_rose_pine_dawn="
  --color=fg:#797593,bg:#faf4ed,hl:#d7827e
  --color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
  --color=border:#dfdad9,header:#286983,gutter:#faf4ed
  --color=spinner:#ea9d34,info:#56949f
  --color=pointer:#907aa9,marker:#b4637a,prompt:#797593"

fzf_rose_pine_moon="
  --color=fg:#908caa,bg:#232136,hl:#ea9a97
  --color=fg+:#e0def4,bg+:#393552,hl+:#ea9a97
  --color=border:#44415a,header:#3e8fb0,gutter:#232136
  --color=spinner:#f6c177,info:#9ccfd8
  --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

export FZF_DEFAULT_OPTS="$fzf_rose_pine_moon"

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND="fd --hidden --follow --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --follow --strip-cwd-prefix --exclude .git"

  # let fzf's tab-completion (**<Tab>) use fd too, instead of its default walker
  _fzf_compgen_path() {
    fd --hidden --follow --exclude .git . "$1"
  }

  _fzf_compgen_dir() {
    fd --type=d --hidden --follow --exclude .git . "$1"
  }
else
  export FZF_CTRL_T_COMMAND="find . \( -name .DS_Store -o -name .git \) -prune -o -print"
  export FZF_DEFAULT_COMMAND="$FZF_CTRL_T_COMMAND"
fi

if (( $+commands[eza] )); then
  fzf_tree_preview="eza --tree --color=always {} | head -200"
else
  fzf_tree_preview="find {} -maxdepth 3 | head -200"
fi

if (( $+commands[bat] )); then
  fzf_file_preview="bat -n --color=always --line-range :500 {}"
else
  fzf_file_preview="cat {}"
fi

fzf_preview="if [ -d {} ]; then $fzf_tree_preview; else $fzf_file_preview; fi"

export FZF_CTRL_T_OPTS="--preview '$fzf_preview'"
export FZF_ALT_C_OPTS="--preview '$fzf_tree_preview'"

# customize previews for fzf-tab-completion (**<Tab>) per command
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview "$fzf_tree_preview"    "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"     "$@" ;;
    ssh)          fzf --preview 'dig {}'               "$@" ;;
    *)            fzf --preview "$fzf_preview"         "$@" ;;
  esac
}

source <(fzf --zsh)
