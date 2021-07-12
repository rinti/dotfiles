vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.inccommand = "nosplit"
vim.o.clipboard = "unnamed"

vim.g.mapleader = " "

require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'
  use 'folke/tokyonight.nvim'
  use 'bkad/CamelCaseMotion'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-sensible'
  use 'airblade/vim-gitgutter'
  use { 'RRethy/vim-hexokinase', run = 'make hexokinase'}
  use 'scrooloose/syntastic'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'tpope/vim-commentary'
  use 'wellle/targets.vim'
  use 'mileszs/ack.vim'
  use 'tpope/vim-vinegar'
  use 'junegunn/fzf.vim'
  use 'glepnir/lspsaga.nvim'
  end
)

require'plugin_settings'
require'keybinds'
require'treesitter'
require'lsp'
