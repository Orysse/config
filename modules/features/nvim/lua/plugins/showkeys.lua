require("showkeys").setup({
  timeout = 2,
  maxkeys = 5,
  position = "bottom-right",
})
vim.keymap.set("n", "<leader>tk", "<cmd>ShowkeysToggle<cr>", { desc = "Toggle Showkeys" })
