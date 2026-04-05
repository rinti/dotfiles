vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.inccommand = "nosplit"
vim.o.clipboard = "unnamed"
vim.o.completeopt = "menuone,noselect"

vim.g.mapleader = " "

-- Run TSUpdate on treesitter install/update
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  'https://github.com/github/copilot.vim',
  'https://github.com/mhartington/formatter.nvim',
  -- Completion
  'https://github.com/hrsh7th/nvim-cmp',
  'https://github.com/hrsh7th/cmp-vsnip',
  'https://github.com/hrsh7th/vim-vsnip',
  'https://github.com/hrsh7th/cmp-buffer',
  'https://github.com/hrsh7th/cmp-path',
  'https://github.com/hrsh7th/cmp-nvim-lsp',
  'https://github.com/hrsh7th/cmp-cmdline',
  'https://github.com/onsails/lspkind-nvim',
  -- Editor
  'https://github.com/editorconfig/editorconfig-vim',
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  'https://github.com/bkad/CamelCaseMotion',
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/tpope/vim-sensible',
  'https://github.com/airblade/vim-gitgutter',
  'https://github.com/kuator/some-python-plugin.nvim',
  'https://github.com/scrooloose/syntastic',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/tpope/vim-commentary',
  'https://github.com/wellle/targets.vim',
  'https://github.com/mileszs/ack.vim',
  'https://github.com/tpope/vim-vinegar',
  'https://github.com/junegunn/fzf',
  'https://github.com/junegunn/fzf.vim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-lua/popup.nvim',
  'https://github.com/windwp/nvim-spectre',
  'https://github.com/kyazdani42/nvim-web-devicons',
  'https://github.com/hoob3rt/lualine.nvim',
  'https://github.com/ggandor/lightspeed.nvim',
  'https://github.com/folke/lsp-trouble.nvim',
})

-- Plugin configs (must be after vim.pack.add)
vim.g.ackprg = 'rg --vimgrep -g "!*migration*"'
vim.g.fzf_buffers_jump = true
vim.g.fzf_nvim_statusline = "0"
vim.g.fzf_files_options = "--preview 'cat {}'"
vim.g.fzf_layout = {window = {width = 0.8, height = 0.4, yoffset = 0.2}}
vim.cmd [[let $FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS . ' --reverse --ansi']]
require("trouble").setup { auto_close = true }

require'settings'
require'keybinds'
require'treesitter'
require'lsp'
require'compe_settings'
require'lualine_settings'
require'formatter_nvim'
