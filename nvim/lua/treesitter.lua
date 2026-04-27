-- Treesitter
-- nvim-treesitter v1 only installs parsers; highlighting must be started per buffer
require('nvim-treesitter').install { "python", "javascript", "typescript", "tsx", "html", "css", "markdown", "markdown_inline" }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'html', 'css', 'markdown' },
  callback = function() pcall(vim.treesitter.start) end,
})
