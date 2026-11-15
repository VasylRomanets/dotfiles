if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND="fd --hidden --follow --strip-cwd-prefix --exclude .git"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --follow --strip-cwd-prefix --exclude .git"

  # Let fzf's tab-completion (**<Tab>) use fd too, instead of its default walker.
  _fzf_compgen_path() {
    fd --hidden --follow --exclude .git . "$1"
  }

  _fzf_compgen_dir() {
    fd --type=d --hidden --follow --exclude .git . "$1"
  }
else
  export FZF_DEFAULT_COMMAND="find . \( -name .DS_Store -o -name .git \) -prune -o -print"
fi

# One script previews directories, binary files and text files alike.
fzf_preview="${XDG_CONFIG_HOME:-$HOME/.config}/fzf/scripts/preview.sh {}"

export FZF_ALT_C_OPTS="--preview '$fzf_preview'"

# Customize previews for fzf-tab-completion (**<Tab>) per command.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview "$fzf_preview"         "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"     "$@" ;;
    ssh)          fzf --preview 'dig {}'               "$@" ;;
    *)            fzf --preview "$fzf_preview"         "$@" ;;
  esac
}

# The fzf --zsh script sourced below binds CTRL-R and CTRL-T unless these
# variables are empty. Set them to empty when atuin and television are
# installed, so those own the keys, and leave fzf's bindings as the fallback
# otherwise.
(( $+commands[atuin] )) && export FZF_CTRL_R_COMMAND=""

if (( $+commands[tv] )); then
  export FZF_CTRL_T_COMMAND=""
else
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview '$fzf_preview'"
fi

# Behavior shared by every fzf call. The colors come from the generated file below.
export FZF_DEFAULT_OPTS="--highlight-line --info=inline-right --cycle --bind=change:first"

# fzf reads its colors from this file on every invocation.
export FZF_DEFAULT_OPTS_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/theme/generated/fzf.conf"

source <(fzf --zsh)
