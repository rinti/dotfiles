-- Ack
vim.g.ackprg = 'rg --vimgrep -g "!*migration*"'

-- Color
vim.o.background = "dark"
vim.g.tokyonight_style = "night"
vim.cmd [[colorscheme tokyonight]]
vim.o.colorcolumn = "100"
vim.cmd [[au VimEnter * highlight ColorColumn guibg=#2c2c3b]]

-- Netrw
vim.g.netrw_liststyle = "4"
vim.g.netrw_banner = "0"
vim.g.netrw_list_hide = '.pyc,.DS_Store,.git'

-- stuff to ignore when tab completing
vim.o.wildignore = "*.pyc,__pycache__/,*DS_Store*,*/node_modules,.git,.gitkeep"

-- fzf
vim.g.fzf_nvim_statusline = "0"
vim.g.fzf_files_options = "--preview 'cat {}'"
