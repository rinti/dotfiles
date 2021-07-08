touch ~/.hushlogin

export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export PATH="/opt/homebrew/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/bin:$HOME/.pyenv__/bin:$HOME/Library/Android/sdk/tools:$PATH";
export PATH="/Users/andreas/.composer/vendor/bin:/Users/andreas/flutter/bin:/usr/local/opt/python/libexec/bin:$PATH"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# export TERM="xterm-256color"

export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@1.1/lib/pkgconfig"

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

HISTFILE=$HOME/.zsh_history
HISTFILESIZE=6553600
HISTSIZE=409600
SAVEHIST=409600
REPORTTIME=60

export GIT_EDITOR='nvim'
export LESS='-imJMWR'
export PAGER="less $LESS"
export MANPAGER=$PAGER
export GIT_PAGER=$PAGER

# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"

alias g="git"
alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gp='git push'
alias gpra='git pull --rebase --autostash'
alias gd='git dsf'
alias glt='git describe --tags `git rev-list --tags --max-count=1`'
alias repo='~/dev'

alias vim="nvim"
alias dcp="docker compose"
alias dcpe="docker compose exec"
alias activate="source venv/bin/activate"

bindkey "^A" vi-beginning-of-line
bindkey "^E" vi-end-of-line
export PATH="/opt/homebrew/sbin:$PATH"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
