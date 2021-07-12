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
  use {
    "junegunn/fzf.vim",
    requires = {
        {"junegunn/fzf"}
    },
    config = function()
        vim.g.fzf_buffers_jump = true
        vim.g.fzf_layout = {window = {width = 0.8, height = 0.4, yoffset = 0.2}}
        vim.cmd [[let $FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS . ' --reverse --ansi']]
    end
  }
  use 'glepnir/lspsaga.nvim'
  use {
  'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }
  use 'ggandor/lightspeed.nvim'
  end
)

require'plugin_settings'
require'keybinds'
require'treesitter'
require'lsp'
require'evil_lualine'
