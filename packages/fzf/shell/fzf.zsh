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
  export FZF_CTRL_T_COMMAND="fd --hidden --follow --exclude .DS_Store --exclude .git"
else
  export FZF_CTRL_T_COMMAND="find . \( -name .DS_Store -o -name .git \) -prune -o -print"
fi

# fzf generates its integration script dynamically via CLI; source_brew_plugin
# expects a static file under $HOMEBREW_PREFIX/share/ and would silently no-op;
# also, 'source <()' (not eval) is required: the script uses 'return' and
# '{ } always { }' (try/finally) which only behave correctly when sourced as a file
source <(fzf --zsh)
