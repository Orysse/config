require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

require("mini.notify").setup()
vim.notify = require("mini.notify").make_notify()
vim.keymap.set("n", "<leader>sn", function() require("mini.notify").show_history() end, { desc = "Notification history" })

require("mini.statusline").setup({
  content = {
    active = function()
      local mode, mode_hl = require("mini.statusline").section_mode({ trunc_width = 120 })
      local filename = require("mini.statusline").section_filename({ trunc_width = 140 })
      local diagnostics = require("mini.statusline").section_diagnostics({ trunc_width = 75 })

      return require("mini.statusline").combine_groups({
        { hl = mode_hl, strings = { mode } },
        "%<",
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineFilename", strings = { diagnostics } },
      })
    end,
  },
})
