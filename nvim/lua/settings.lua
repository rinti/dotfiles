-- color
-- vim.o.background = "dark"
-- vim.g.tokyonight_style = "storm"
-- vim.cmd [[colorscheme tokyonight]]

-- vim.cmd.colorscheme 'nordic'
vim.cmd.colorscheme 'kanagawa'

vim.o.colorcolumn = "100"
vim.cmd [[au VimEnter * highlight ColorColumn guibg=#2c2c3b]]

-- Netrw
vim.g.netrw_liststyle = "4"
vim.g.netrw_banner = "0"
vim.g.netrw_list_hide = '.pyc,.DS_Store,.git'

-- stuff to ignore when tab completing
vim.o.wildignore = "*.pyc,__pycache__/,*DS_Store*,*/node_modules,.git,.gitkeep"

-- vim.cmd [[
--   autocmd!
--   autocmd BufWritePost * FormatWrite
-- ]]

local node_bin =  "/Users/andreas/.asdf/installs/nodejs/18.9.0/bin/node"
-- vim.g.node_host_prog = node_bin
vim.cmd("let $PATH = '" .. node_bin .. ":' . $PATH")
vim.g.copilot_node_command = node_bin -- Node.js version must be > 16.x
