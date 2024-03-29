local api, g = vim.api, vim.g
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    api.nvim_set_keymap(mode, lhs, rhs, options)
end

g["mapleader"] = " " -- Map space as leader

--
-- Keybinds
-----------
vim.api.nvim_set_keymap('n', 'j', 'gj', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'k', 'gk', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'J', '5j', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'K', '5k', {noremap = true, silent = true})

-- Ctrl + J/K moves selected lines down/up in visual mode
vim.api.nvim_set_keymap('v', '<C-j>', ':m \'>+1<CR>gv=gv', {noremap = true})
vim.api.nvim_set_keymap('v', '<C-k>', ':m \'<-2<CR>gv=gv', {noremap = true})

-- Switch windows with arrows
vim.api.nvim_set_keymap('n', '<Left>', ':wincmd h<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Right>', ':wincmd l<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Up>', ':wincmd k<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Down>', ':wincmd j<CR>', {noremap = true, silent = true})

-- Change window size with shift + arrows
vim.api.nvim_set_keymap('n', '<S-Left>', ':vertical resize +1<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-Right>', ':vertical resize -1<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-Up>', ':resize resize +1<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-Down>', ':resize resize -1<CR>', {noremap = true, silent = true})

-- Remove highlight with ESC ESC
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':nohlsearch<CR>', {noremap = true, silent = true})

-- Open find file with ff
vim.api.nvim_set_keymap('n', '<Leader>ff', ':Files<CR>', {noremap = true, silent = true})
-- Switch to previous buffer with leader leader
vim.api.nvim_set_keymap('n', '<Leader><Leader>', '<c-^>', {noremap = true, silent = true})

-- Convenience keys for going to beginning / end of line in insert mode
vim.api.nvim_set_keymap('i', '<C-e>', '<C-o>$', {})
vim.api.nvim_set_keymap('i', '<C-a>', '<C-o>0', {})
vim.api.nvim_set_keymap('i', '<C-f>', '<C-o>l', {})
vim.api.nvim_set_keymap('i', '<C-b>', '<C-o>h', {})

-- Exit insertmode with jj
vim.api.nvim_set_keymap('i', 'jj', '<ESC>', {})

-- Bind jj to exit terminal
vim.api.nvim_set_keymap('t', 'jj', '<C-\\><C-n>', {noremap = true, silent = true})

-- Search for occurrances using Ack
vim.api.nvim_set_keymap('', '<Leader>a', ':Ack!<space>', {})

-- CamelCase motion
vim.api.nvim_set_keymap('', 'W', '<Plug>CamelCaseMotion_w', {silent = true})
vim.api.nvim_set_keymap('', 'E', '<Plug>CamelCaseMotion_e', {silent = true})
vim.api.nvim_set_keymap('', 'B', '<Plug>CamelCaseMotion_b', {silent = true})

vim.api.nvim_set_keymap('o', 'iW', '<Plug>CamelCaseMotion_iw', {silent = true})
vim.api.nvim_set_keymap('x', 'iW', '<Plug>CamelCaseMotion_iw', {silent = true})
vim.api.nvim_set_keymap('o', 'iE', '<Plug>CamelCaseMotion_ie', {silent = true})
vim.api.nvim_set_keymap('x', 'iE', '<Plug>CamelCaseMotion_ie', {silent = true})
vim.api.nvim_set_keymap('o', 'iB', '<Plug>CamelCaseMotion_ib', {silent = true})
vim.api.nvim_set_keymap('x', 'iB', '<Plug>CamelCaseMotion_ib', {silent = true})


-- LSP
-- vim.api.nvim_set_keymap('n', 'ff', ':Lspsaga lsp_finder<CR>', {silent = true, noremap = true})
-- vim.api.nvim_set_keymap('n', '<leader>ca', ':Lspsaga code_action<CR>', {silent = true, noremap = true})
-- vim.api.nvim_set_keymap('v', '<leader>ca', ':<C-U>Lspsaga range_code_action<CR>', {silent = true, noremap = true})
-- vim.api.nvim_set_keymap('n', 'K', ':Lspsaga hover_doc<CR>', {silent = true, noremap = true})
-- vim.api.nvim_set_keymap('n', 'fr', ':Lspsaga rename<CR>', {silent = true, noremap = true})
-- vim.api.nvim_set_keymap('n', 'fd', ':Lspsaga preview_definition<CR>', {silent = true, noremap = true})


map("n", "fc", "<cmd>FormatWrite<CR>", { noremap = true, silent = true }) -- lsp
map("n", "ff", "<cmd>lua vim.lsp.buf.declaration()<CR>", { noremap = true, silent = true }) -- lsp
map("n", "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { noremap = true, silent = true }) -- lsp
-- map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true }) -- lsp
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true }) -- lsp
map("n", "fi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { noremap = true, silent = true }) -- lsp
map("n", "fr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = true }) -- lsp
map("n", "KK", "<cmd>lua vim.diagnostic.open_float({scope='line', width=80})<CR>", { noremap = true, silent = true }) -- lsp
map("n", "<leader>f", "<cmd>lua vim.lsp.buf.format { async = true }<CR>", { noremap = true, silent = true }) -- lsp
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true }) --lsp
map("n", "<leader>x", "<cmd>TroubleToggle<cr>", { noremap = true, silent = true }) --lsp-trouble


vim.api.nvim_set_keymap('i', '<C-j>', 'copilot#Accept("<CR>")', {expr=true, silent=true})

g['copilot_no_tab_map'] = true
g['copilot_assume_mapped'] = true
