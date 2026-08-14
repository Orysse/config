vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  signs = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
    map("n", "gr", vim.lsp.buf.references, "Goto References")
    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
    map("n", "gT", vim.lsp.buf.type_definition, "Type Definition")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
    map("n", "<leader>cw", vim.lsp.buf.workspace_symbol, "Workspace Symbol")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

    map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
    map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.enable({
  "lua_ls",
  "nixd",
  "ts_ls",
  "pyright",
  "jsonls",
  "gopls",
})

vim.lsp.config("eslint", {
  settings = { workingDirectories = { mode = "auto" } },
})
vim.lsp.enable("eslint")

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  capabilities = { offsetEncoding = { "utf-16" } },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})
vim.lsp.enable("clangd")

vim.lsp.config("rust_analyzer", {
  settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})
vim.lsp.enable("rust_analyzer")

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      validate = true,
      hover = true,
      completion = true,
      schemaStore = { enable = false, url = "" },
      schemas = vim.tbl_extend("force", require("schemastore").yaml.schemas(), {
        ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
          ".gitlab-ci.yml",
          ".gitlab-ci/**/*.yml",
          ".gitlab-ci/**/*.yaml",
          "gitlab-ci/**/*.yml",
          "gitlab-ci/**/*.yaml",
        },
      }),
    },
  },
})
vim.lsp.enable("yamlls")

vim.lsp.enable({ "hls", "ocamllsp", "cmake", "tofu_ls", "ansiblels", "bicep" })

vim.lsp.enable("postgres_lsp")

local ok_info, nix_info = pcall(require, "nix-info")
if ok_info and nix_info.info and nix_info.info.powershellBundlePath then
  vim.lsp.config("powershell_es", { bundle_path = nix_info.info.powershellBundlePath })
  vim.lsp.enable("powershell_es")
end

vim.lsp.config("helm_ls", {
  settings = {
    ["helm-ls"] = {
      yamlls = { path = vim.fn.exepath("yaml-language-server") },
    },
  },
})
vim.lsp.enable("helm_ls")
