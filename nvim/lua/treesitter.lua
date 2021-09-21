-- Treesitter
--
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "javascript", "typescript", "elixir", "php", "html", "css" }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = { }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = { },  -- list of language that will be disabled
  },
}
