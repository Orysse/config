require("snacks").setup({
  bigfile = { enabled = true },
  picker = {
    enabled = true,
    actions = require("trouble.sources.snacks").actions,
    formatters = { file = { filename_first = true } },
    matcher = { frecency = true },
    win = {
      input = {
        keys = {
          ["<c-t>"] = { "trouble_open", mode = { "n", "i" } },
        },
      },
    },
  },
})

local map = vim.keymap.set
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<C-p>", function() Snacks.picker.git_files() end, { desc = "Git files" })
map("n", "<leader>fg", function() Snacks.picker.recent() end, { desc = "Recent files" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<leader>lg", function() Snacks.picker.grep() end, { desc = "Live grep" })
map("n", "<leader>sb", function() Snacks.picker.grep_buffers() end, { desc = "Search buffer" })
map("n", "<leader>gc", function() Snacks.picker.git_log() end, { desc = "Git commits" })
map("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git status" })
map("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git branches" })
map("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help pages" })
map("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands" })
map("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "Command history" })
map("n", "<leader>sd", function() Snacks.picker.diagnostics_buffer() end, { desc = "Document diagnostics" })
map("n", "<leader>sD", function() Snacks.picker.diagnostics() end, { desc = "Workspace diagnostics" })
map("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end, { desc = "LSP symbols" })
