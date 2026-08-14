require("fidget").setup({
  progress = {
    display = {
      done_icon = "✔",
      overrides = { rust_analyzer = { name = "rust-analyzer" } },
    },
  },
  notification = {
    window = { winblend = 0 },
  },
})
