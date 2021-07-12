-- Lsp
--
-- Python: npm i -g pyright
-- TS: npm install -g typescript typescript-language-server diagnostic-languageserver eslint_d

local nvim_lsp = require("lspconfig")

nvim_lsp.pyright.setup {}
nvim_lsp.tsserver.setup {}
