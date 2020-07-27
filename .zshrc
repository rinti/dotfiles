touch ~/.hushlogin

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/bin:$HOME/.pyenv/bin:$PATH";
export PATH="/Users/andreas/repositories/flutter/bin:/usr/local/opt/python/libexec/bin:$PATH"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export TERM="xterm-256color"

# NVM
# export NVM_DIR="$HOME/.nvm"
# [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

# fzf
export FZF_DEFAULT_COMMAND='rg --files --ignore-case --follow --glob "!.git/*" '
export FZF_CTRL_T_COMMAND='fd -a -t d . $HOME'

# vim bindings
bindkey -v

# allow comments
set -k

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
alias nvms='. $NVM_DIR/nvm.sh'

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

alias g="git"
alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gp='git push'
alias gd='git dsf'
alias glt='git describe --tags `git rev-list --tags --max-count=1`'
alias repo='~/repositories'

alias vim="nvms && nvim"
alias dcp="docker-compose"
alias dcpe="docker-compose exec"

bindkey "^A" vi-beginning-of-line
bindkey "^E" vi-end-of-line
