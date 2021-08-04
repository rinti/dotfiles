-- Keybinds
-----------
vim.api.nvim_set_keymap('n', 'j', 'gj', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'k', 'gk', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'J', '5j', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'K', '5k', {noremap = true, silent = true})

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
vim.api.nvim_set_keymap('n', 'ff', ':Lspsaga lsp_finder<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>ca', ':Lspsaga code_action<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('v', '<leader>ca', ':<C-U>Lspsaga range_code_action<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', 'K', ':Lspsaga hover_doc<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', 'fr', ':Lspsaga rename<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', 'fd', ':Lspsaga preview_definition<CR>', {silent = true, noremap = true})

-- Compe
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
    return true
  else
    return false
  end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn["compe#complete"]()
  end
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

local opts = {expr = true, silent = true, noremap=true}
vim.api.nvim_set_keymap("i", "<C-Space>", "compe#complete()", opts)
vim.api.nvim_set_keymap("i", "<CR>", "compe#confirm('<CR>')", opts)
-- vim.api.nvim_set_keymap("i", "<C-e>", "compe#close('<C-e>')", opts)
-- vim.api.nvim_set_keymap("i", "<C-f>", "compe#scroll({ 'delta': +4 })", opts)
-- vim.api.nvim_set_keymap("i", "<C-d>", "compe#scroll({ 'delta': -4 })", opts)

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
