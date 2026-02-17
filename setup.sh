## Remove date at top of terminal
#touch ~/.hushlogin
#
##if [[ "$OSTYPE" == "linux-gnu"* ]]; then
##    ./linux.sh
##else
##    ./brew.sh
##fi
#
## Git
#ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
#
## tmux
#ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
#
## zsh
#ln -sf ~/dotfiles/.zshrc ~/.zshrc
#ln -sf ~/dotfiles/.zpreztorc ~/.zpreztorc
#
## fd
#ln -sf ~/dotfiles/.fdignore ~/.fdignore
#
## Nvm
#mkdir -p ~/.nvm 2> /dev/null || true
#
## Nvim
mkdir -p ~/.config/nvim 2> /dev/null || true
ln -sfn ~/dotfiles/nvim ~/.config/nvim

# vscode
#ln -sf ~/dotfiles/vscode/snippets/ ~/Library/Application\ Support/Code/User/
#ln -sf ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
#ln -sf ~/dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json

# tmux
#git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# mise
#curl https://mise.run | sh

# ghostty
mkdir -p ~/.config/ghostty 2> /dev/null || true
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config

# claude
mkdir -p ~/.claude 2> /dev/null || true
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/claude/settings.json ~/.claude/settings.json
ln -sfn ~/dotfiles/claude/skills ~/.claude/skills
ln -sfn ~/dotfiles/claude/commands ~/.claude/commands
ln -sfn ~/dotfiles/claude/hooks ~/.claude/hooks

# agents (mirror claude skills into ~/.agents/skills without replacing ~/.agents)
mkdir -p ~/.agents/skills 2> /dev/null || true
for skill_dir in ~/dotfiles/claude/skills/*; do
  [ -d "$skill_dir" ] || continue
  ln -sfn "$skill_dir" "$HOME/.agents/skills/$(basename "$skill_dir")"
done

# launchd agents
mkdir -p ~/Library/LaunchAgents 2> /dev/null || true
ln -sf ~/dotfiles/launchd/com.user.twd.plist ~/Library/LaunchAgents/com.user.twd.plist
launchctl load ~/Library/LaunchAgents/com.user.twd.plist 2> /dev/null || true
