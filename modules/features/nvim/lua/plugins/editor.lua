require("flash").setup({
  jump = { autojump = true },
})
local map = vim.keymap.set
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash treesitter jump" })

require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.ai").setup({ n_lines = 500 })
require("mini.align").setup()
require("mini.indentscope").setup({
  symbol = "│",
  options = { try_as_border = true },
})

require("render-markdown").setup({
  indent = { enabled = false },
  code = { width = "block", position = "left", right_pad = 5, border = "thick" },
  dash = { width = 100 },
  file_types = { "markdown", "quarto" },
})

vim.g.undotree_DiffAutoOpen = 1
vim.g.undotree_SetFocusWhenToggle = 1
vim.keymap.set("n", "<leader>ut", "<cmd>UndotreeToggle<CR>", { desc = "Undotree", silent = true })
