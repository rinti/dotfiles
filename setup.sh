# Remove date at top of terminal
touch ~/.hushlogin

#if [[ "$OSTYPE" == "linux-gnu"* ]]; then
#    ./linux.sh
#else
#    ./brew.sh
#fi

# Git
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# tmux
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

# zsh
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.zpreztorc ~/.zpreztorc

# fd
ln -sf ~/dotfiles/.fdignore ~/.fdignore

# Nvm
mkdir -p ~/.nvm 2> /dev/null || true

# Nvim
mkdir -p ~/.config/nvim 2> /dev/null || true
ln -sf ~/dotfiles/nvim ~/.config/nvim

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
