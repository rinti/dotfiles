
touch ~/.hushlogin

# eval "$(~/.local/bin/mise activate zsh)"

alias dn='vim ~/notes/$(date +%F).txt'

# export PATH="/usr/local/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/opt/homebrew/opt/openssl@1.1/bin:$PATH"
# export PATH="/opt/homebrew/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
# export PATH="$HOME/bin:$HOME/.pyenv__/bin:$HOME/Library/Android/sdk/tools:$PATH";
# export PATH="/Users/andreas/.composer/bin:/Users/andreas/flutter/bin:/usr/local/opt/python/libexec/bin:$PATH"

# export PATH="/opt/local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# export PATH="$HOME/.local/share/mise/installs/python/3.11.1/bin:$HOME/.local/bin:$HOME/.bun/bin"
# export PATH="$HOME/.composer/bin:$HOME/flutter/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin"
# export PATH="$HOME/bin:$HOME/.pyenv__/bin:$HOME/Library/Android/sdk/tools"
# export PATH="/usr/local/opt/python/libexec/bin:/opt/homebrew/sbin:/opt/homebrew/opt/openssl@1.1/bin"
# export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
#
export PATH="/opt/local/bin"
export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
export PATH="$PATH:/usr/local/bin:/usr/local/opt/python/libexec/bin"
export PATH="$PATH:$HOME/.local/share/mise/installs/python/3.11.1/bin:$HOME/.local/bin:$HOME/.bun/bin"
export PATH="$PATH:$HOME/.composer/bin:$HOME/flutter/bin"
export PATH="$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin"
export PATH="$PATH:$HOME/bin:$HOME/.pyenv__/bin:$HOME/Library/Android/sdk/tools"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"

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
#
# vim bindings
bindkey -v

# allow comments
set -k

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --ignore-case --follow --glob "!.git/*" '
export FZF_CTRL_T_COMMAND='fd -a -t d . $HOME'


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
alias gd='git diff'
alias glt='git describe --tags `git rev-list --tags --max-count=1`'
alias repo='~/dev'

alias vim="nvim"
alias dcp="docker compose"
alias dcpe="docker compose exec"
alias activate="source venv/bin/activate"
# alias aa="activate_asdf; activate"
alias aa="activate"
alias oci="cd $(git rev-parse --show-toplevel) && make open_ci && cd -"
# alias fc='pushd $(git rev-parse --show-toplevel) > /dev/null && FILES=$(git diff --name-only -- "*.py"; git ls-files --others --exclude-standard -- "*.py") && echo "$FILES" | xargs black && echo "$FILES" | xargs isort --profile black && popd > /dev/null'
# alias fc='ROOT_DIR=$(git rev-parse --show-toplevel) && CURRENT_DIR=$(pwd) && \
# [ "$ROOT_DIR" != "$CURRENT_DIR" ] && pushd "$ROOT_DIR" > /dev/null; \
# FILES=$(git diff --name-only -- "*.py"; git ls-files --others --exclude-standard -- "*.py") && \
# echo "$FILES" | xargs black && echo "$FILES" | xargs isort --profile black; \
# [ "$ROOT_DIR" != "$CURRENT_DIR" ] && popd > /dev/null'
alias fc='
  ROOT_DIR=$(git rev-parse --show-toplevel) && 
  CURRENT_DIR=$(pwd) && 
  [ "$ROOT_DIR" != "$CURRENT_DIR" ] && pushd "$ROOT_DIR" > /dev/null && 
  FILES=$(git diff --name-only --diff-filter=AM -- "*.py"; git ls-files --others --exclude-standard -- "*.py") && 
  echo "$FILES" | xargs black && 
  echo "$FILES" | xargs isort --profile black && 
  [ "$ROOT_DIR" != "$CURRENT_DIR" ] && popd > /dev/null
'

alias rns="tmux rename-session"
alias rnw="tmux rename-window"
alias tms="/Users/andreas/dotfiles/twd.sh && /Users/andreas/dotfiles/tmuxsession.sh"

# alias activate_asdf='. /opt/homebrew/opt/asdf/libexec/asdf.sh'

alias install_lsp='activate_asdf; npm i -g pyright typescript typescript-language-server diagnostic-languageserver eslint_d vscode-langservers-extracted svelte-language-server'

bindkey "^A" vi-beginning-of-line
bindkey "^E" vi-end-of-line
export PATH="/opt/homebrew/sbin:$PATH"

# source /Users/andreas/.docker/init-zsh.sh || true # Added by Docker Desktop


# bun completions
[ -s "/Users/andreas/.bun/_bun" ] && source "/Users/andreas/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"



# . "$HOME/.local/bin/env"
eval "$(/Users/andreas/.local/bin/mise activate zsh)"

# Scaleway CLI autocomplete initialization.
eval "$(scw autocomplete script shell=zsh)"

alias claude="/Users/andreas/.claude/local/claude"
