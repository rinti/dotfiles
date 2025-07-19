-- Lsp
--
-- Python: npm i -g pyright
-- TS: npm install -g typescript typescript-language-server diagnostic-languageserver eslint_d
-- json: npm i -g vscode-langservers-extracted
-- svelte: npm install -g svelte-language-server
-- css, html: npm i -g vscode-langservers-extracted
--
vim.diagnostic.config({
  virtual_text = false, -- Turn off inline diagnostics
})
vim.api.nvim_set_keymap(
  'n', '<Leader>d', ':lua vim.diagnostic.open_float()<CR>', 
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  'n', '<Leader>n', ':lua vim.diagnostic.goto_next()<CR>',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  'n', '<Leader>p', ':lua vim.diagnostic.goto_prev()<CR>',
  { noremap = true, silent = true }
)

local nvim_lsp = require("lspconfig")



local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
-- capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.set_log_level("debug")

local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'v', '<leader>ca', '<cmd>lua vim.lsp.buf.range_code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

local servers = {
    -- 'pyright',
    -- 'jedi_language_server',
    'ts_ls',
    'jsonls',
    'svelte',
    'cssls',
    'html'
}

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

nvim_lsp.intelephense.setup({
    settings = {
        intelephense = {
            stubs = { 
                "bcmath",
                "bz2",
                "calendar",
                "Core",
                "curl",
                "zip",
                "zlib",
                "wordpress",
                "woocommerce",
                "acf-pro",
                "wordpress-globals",
                "wp-cli",
                "genesis",
                "polylang"
            },
            files = {
                maxSize = 5000000;
            };
        };
    }
});

local util = require 'lspconfig/util'

nvim_lsp.pyright.setup({
    root_dir = function(fname)
        local root_files = {
            'docker-compose.yml',
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            'pyrightconfig.json',
        }
        return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
    end,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = false,
                typeCheckingMode = "off",
            },
        },
    }
});

-- require 'pylance'
-- nvim_lsp.pylance.setup{
--     on_attach = on_attach,
--     capabilities = capabilities,
--     settings = {
--         python = {
--             analysis = {
--                 typeCheckingMode = "off"
--             },
--         }
--     }
-- }

-- nvim_lsp.pyright.setup {}
-- -- nvim_lsp.jedi_language_server.setup {}
-- -- nvim_lsp.pyright.setup {}
-- -- nvim_lsp.jedi_language_server.setup {}
-- nvim_lsp.tsserver.setup {}
-- nvim_lsp.jsonls.setup {}
-- nvim_lsp.svelte.setup {}
-- nvim_lsp.cssls.setup {
--   capabilities = capabilities,
-- }
-- nvim_lsp.html.setup {
--   capabilities = capabilities,
-- }
-- -- nvim_lsp.elixirls.setup {
-- --     cmd = { "/Users/andreas/languageservers/elixir-ls/language_server.sh" };
-- -- }
