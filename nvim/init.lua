vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.inccommand = "nosplit"
vim.o.clipboard = "unnamed"
vim.o.completeopt = "menuone,noselect"

vim.g.mapleader = " "

require('packer').startup(function()
    use 'github/copilot.vim'
    use 'wbthomason/packer.nvim'
    use 'mhartington/formatter.nvim'
    use {
        "hrsh7th/nvim-cmp",
        requires = {
            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-cmdline",
            "neovim/nvim-lspconfig",
            "onsails/lspkind-nvim",
        }
    }
    use 'editorconfig/editorconfig-vim'
    use 'neovim/nvim-lspconfig'
    -- use 'folke/tokyonight.nvim'
    -- use 'rebelot/kanagawa.nvim'
    -- use 'AlexvZyl/nordic.nvim'
    use 'serhez/teide.nvim'

    use 'bkad/CamelCaseMotion'
    use 'tpope/vim-fugitive'
    use 'tpope/vim-sensible'
    use 'airblade/vim-gitgutter'
    use {
        "kuator/some-python-plugin.nvim",
    }
    use 'scrooloose/syntastic'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'tpope/vim-commentary'
    use 'wellle/targets.vim'
    use {
        'mileszs/ack.vim',
        config = function()
            vim.g.ackprg = 'rg --vimgrep -g "!*migration*"'
        end
    }
    use 'tpope/vim-vinegar'
    use {
        "junegunn/fzf.vim",
        requires = {
            {"junegunn/fzf"}
        },
        config = function()
            vim.g.fzf_buffers_jump = true
            vim.g.fzf_nvim_statusline = "0"
            vim.g.fzf_files_options = "--preview 'cat {}'"
            vim.g.fzf_layout = {window = {width = 0.8, height = 0.4, yoffset = 0.2}}
            vim.cmd [[let $FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS . ' --reverse --ansi']]
        end
    }
    use 'nvim-lua/plenary.nvim'
    use 'nvim-lua/popup.nvim'
    use 'windwp/nvim-spectre'
    use {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup {}
        end
    }
    use {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup {
                automatic_installation = true,
            }
        end
    }
    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true} -- https://www.nerdfonts.com/font-downloads
        -- https://github.com/epk/SF-Mono-Nerd-Font
        -- https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Iosevka/Regular/complete/Iosevka%20Nerd%20Font%20Complete%20Mono.ttf
    }
    use 'ggandor/lightspeed.nvim'
    use {
        "folke/lsp-trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {
                auto_close = true,
            }
        end
    }
end
)

require'settings'
require'keybinds'
require'treesitter'
require'lsp'
require'compe_settings'
require'lualine_settings'
require'formatter_nvim'
