if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
alias nv="nvim"


source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
alias ls="eza --icons=always"

eval "$(zoxide init zsh)"

alias cd="z"
source ~/powerlevel10k/powerlevel10k.zsh-theme

export PATH="/Users/alexmatthewcandelario/gits/Odin:$PATH"
export PATH="/Users/alexmatthewcandelario/bins/jai/bin:$PATH"
export PATH="/Users/alexmatthewcandelario/projects/coder/build:$PATH"
export PATH="/Users/alexmatthewcandelario/Gits/coder/build:$PATH" 


export PATH="/Users/alexmatthewcandelario/bins:$PATH"

alias jai="jai-macos"
export FZF_DEFAULT_COMMAND="rg --files --hidden -g'!.git'"
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse"

# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi


export PATH="/usr/local/opt/llvm/bin:$PATH"
# Set up fzf key bindings and fuzzy completion
export EDITOR=nvim
alias fh="history | fzf"
alias fh="history | fzf | vim -"

export PATH="$HOME/.local/bin:$PATH"
alias claude2="CLAUDE_CONFIG_DIR=~/.claude-personal claude"
