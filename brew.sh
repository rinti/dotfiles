#!/usr/bin/env bash

brew update
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
brew install zsh
brew install neovim
brew install grep
brew install openssh
brew install git
brew install git-flow
brew install tree
brew install ripgrep
brew install fzf
brew install fd
brew install reattach-to-user-namespace

brew cleanup
