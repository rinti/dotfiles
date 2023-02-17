local prettierFmt = function()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), "--single-quote", "--tab-width 2"},
    stdin = true
  }
end

local blackFmt = function()
    return {
      exe = "black", -- this should be available on your $PATH
      args = { '-' },
      stdin = true,
    }
end

local isortFmt = function()
    return {
      exe = "isort", -- this should be available on your $PATH
      args = { '-q - --multi-line 3 --trailing-comma --line-length 88 --force-grid-wrap 0 --use-parentheses --ensure-newline-before-comments' },
      stdin = true,
    }
end

require('formatter').setup({
  logging = true,
  filetype = {
    scss = {
        prettierFmt
    },
    css = {
        prettierFmt
    },
    javascript = {
        prettierFmt
    },
    json = {
        prettierFmt
    },
    python = {
        isortFmt, blackFmt
    }
  },
})

