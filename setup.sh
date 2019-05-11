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
mkdir ~/.config 2> /dev/null || true && mkdir ~/.config/nvim 2> /dev/null || true
ln -sf ~/dotfiles/.nvimrc ~/.config/nvim/init.vim
mkdir ~/.cache 2> /dev/null || true && mkdir ~/.cache/dein 2> /dev/null || true
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
sh ./installer.sh ~/.cache/dein
