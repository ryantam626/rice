# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_AUTO_TITLE="true"
export EDITOR="nvim"

plugins=(git fzf zsh-completions zsh-syntax-highlighting docker docker-compose task)
zstyle ':completion:*:*:make:*' tag-order 'targets'
autoload -Uz compinit && compinit

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias vim=nvim

# Node Version Manager {{
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# }}

# pnpm {{
export PNPM_HOME="/home/ryan/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# }}

# pyenv {{
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# }}

# thefuck {{
eval $(thefuck --alias)
# }}

# poetry {{
export PATH="/home/ryan/.local/bin:$PATH"
# }}

# gcloud {{
export PATH="/home/ryan/apps/gcloud/google-cloud-sdk/bin:$PATH"
# }}

# Some common aliases that are shared across my machines
alias copy="xsel -b"
alias clc="git rev-parse HEAD | copy"  # Copy last commit hash
alias gc-="git checkout -"
alias gcn="git commit --no-verify"
alias gcor='gco $(grecent | fzf)'
alias gma="git checkout master"
alias grecent="git for-each-ref --sort=-committerdate --count=20 --format='%(refname:short)' refs/heads/"
alias gsh="git show"
alias rt="gb | grep rt."

# zoxide {{
eval "$(zoxide init zsh)"
# }}
