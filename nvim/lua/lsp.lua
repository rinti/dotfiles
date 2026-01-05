-- Lsp
--
-- Python: npm i -g pyright
-- TS: npm install -g typescript typescript-language-server diagnostic-languageserver eslint_d
-- json: npm i -g vscode-langservers-extracted
-- svelte: npm install -g svelte-language-server
-- css, html: npm i -g vscode-langservers-extracted
--
vim.diagnostic.config({
  virtual_text = false,
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

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

vim.lsp.set_log_level("warn")

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.cmd [[ command! Format execute 'lua vim.lsp.buf.format()' ]]
  end,
})

vim.lsp.config('*', {
  capabilities = capabilities,
})

local servers = {
    'ts_ls',
    'jsonls',
    'svelte',
    'cssls',
    'html'
}

for _, server in ipairs(servers) do
  vim.lsp.config(server, {})
end

vim.lsp.config('intelephense', {
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
                maxSize = 5000000,
            },
        },
    }
})

vim.lsp.config('basedpyright', {
    root_markers = {
        'docker-compose.yml',
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
    },
    settings = {
        python = {
            venvPath = ".",
            venv = "venv",
        },
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "off",
            },
        },
    }
})

vim.lsp.enable({ 'ts_ls', 'jsonls', 'svelte', 'cssls', 'html', 'intelephense', 'basedpyright' })

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
