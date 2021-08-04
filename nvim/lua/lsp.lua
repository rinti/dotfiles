-- Lsp
--
-- Python: npm i -g pyright
-- TS: npm install -g typescript typescript-language-server diagnostic-languageserver eslint_d
-- json: npm i -g vscode-langservers-extracted
-- svelte: npm install -g svelte-language-server
-- css, html: npm i -g vscode-langservers-extracted

local nvim_lsp = require("lspconfig")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

nvim_lsp.pyright.setup {}
-- nvim_lsp.jedi_language_server.setup {}
-- nvim_lsp.pyright.setup {}
-- nvim_lsp.jedi_language_server.setup {}
nvim_lsp.tsserver.setup {}
nvim_lsp.jsonls.setup {}
nvim_lsp.svelte.setup {}
nvim_lsp.cssls.setup {
  capabilities = capabilities,
}
nvim_lsp.html.setup {
  capabilities = capabilities,
}
-- nvim_lsp.elixirls.setup {
--     cmd = { "/Users/andreas/languageservers/elixir-ls/language_server.sh" };
-- }
