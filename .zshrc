touch ~/.hushlogin

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/bin:$PATH";
export PATH="/Users/andreas/repositories/flutter/bin:/usr/local/opt/python/libexec/bin:$PATH"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# NVM
# export NVM_DIR="$HOME/.nvm"
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

# fzf
export FZF_DEFAULT_COMMAND='rg --files --ignore-case --follow --glob "!.git/*" '

# vim bindings
bindkey -v

# allow comments
set -k

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias nvms='. /usr/local/opt/nvm/nvm.sh'

alias g="git"
alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gp='git push'
alias gd='git dsf'
alias glt='git describe --tags `git rev-list --tags --max-count=1`'

alias vim="nvim"
alias dcp="docker-compose"
alias dcpe="docker-compose exec"
