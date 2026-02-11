# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

plugins=(git)
alias o="opencode"
alias pip="pip3"
alias py="python"
alias python="python3"
alias v="nvim"

# export HOMEBREW_PREFIX="/usr/local"  # for intel
export HOMEBREW_PREFIX="/opt/homebrew" # for apple silicon
export PATH="$HOMEBREW_PREFIX/bin:$PATH"

export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# See https://formulae.brew.sh/formula/zsh-autosuggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# See https://formulae.brew.sh/formula/zsh-syntax-highlighting
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# opencode
export PATH=/Users/ensia96/.opencode/bin:$PATH
