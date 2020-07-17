# Remove date at top of terminal
touch ~/.hushlogin

# Git
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# Bash
ln -sf ~/dotfiles/.bash_prompt ~/.bash_prompt
ln -sf ~/dotfiles/.bash_profile ~/.bash_profile
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.aliases ~/.aliases

# Nvm
mkdir ~/.nvm 2> /dev/null || true

# Nvim
mkdir -p ~/.config/nvim 2> /dev/null || true
ln -sf ~/dotfiles/.nvimrc ~/.config/nvim/init.vim

# vimplug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
