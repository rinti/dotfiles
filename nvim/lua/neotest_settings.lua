require("neotest").setup({
  adapters = {
    require("neotest-python")({
        dap = { justMyCode = false },
        args = {"-c", "pytest.local.ini"},
        runner = "pytest"
    }),
    require("neotest-plenary"),
  },
})
