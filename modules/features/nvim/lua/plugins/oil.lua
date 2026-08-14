require("oil").setup({
  columns = { "icon" },
  keymaps = {
    ["-"] = { "actions.parent", desc = "Open parent directory" },
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil" })
