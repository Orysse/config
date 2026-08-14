require("conform").setup({
  notify_on_error = true,

  formatters = {
    black = { command = "black" },
    isort = { command = "isort" },
    nixfmt = { command = "treefmt", args = { "--stdin", "$FILENAME" } },
    ocamlformat = { command = "ocamlformat" },
    prettierd = { command = "prettierd" },
    eslint_d = { command = "eslint_d" },
    stylua = { command = "stylua" },
    shellcheck = { command = "shellcheck" },
    shfmt = { command = "shfmt" },
    shellharden = { command = "shellharden" },
    jq = { command = "jq" },
    bicep = { command = "bicep" },
    rustfmt = { command = "rustfmt" },
  },

  formatters_by_ft = {
    html = { "prettierd" },
    css = { "prettierd" },
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    markdown = { "prettierd" },
    yaml = { "prettierd" },
    python = { "black", "isort" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    rust = { "rustfmt" },
    lua = { "stylua" },
    bash = { "shellcheck", "shellharden", "shfmt" },
    json = { "jq" },
    terraform = { "terraform_fmt" },
    bicep = { "bicep" },
    ocaml = { "ocamlformat" },
    javascriptreact = { "eslint_d" },
    ["javascript.jsx"] = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    ["typescript.tsx"] = { "eslint_d" },
    vue = { "eslint_d" },
    svelte = { "eslint_d" },
    astro = { "eslint_d" },
    nix = { "nixfmt" },
    ["_"] = { "trim_whitespace" },
  },

  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { lsp_format = "fallback", timeout_ms = 500 }
  end,
})

local map = vim.keymap.set

map("n", "<leader>tf", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify(vim.g.disable_autoformat and "Format on save disabled" or "Format on save enabled", vim.log.levels.INFO)
end, { desc = "Toggle format on save (global)" })

map("n", "<leader>tF", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify(
    vim.b.disable_autoformat and "Format on save disabled (buffer)" or "Format on save enabled (buffer)",
    vim.log.levels.INFO
  )
end, { desc = "Toggle format on save (buffer)" })

map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer/selection" })
