vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype
    if pcall(vim.treesitter.language.add, lang) and pcall(vim.treesitter.start, nil, lang) then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})
