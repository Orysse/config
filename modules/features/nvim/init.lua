vim.g.mapleader = " "

vim.g.clipboard = {
	name = "wl-clipboard",
	copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
	paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
	cache_enabled = true,
}

local opt = vim.opt
opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldmethod = "indent"

opt.smartindent = true
opt.breakindent = true

opt.wrap = false

opt.swapfile = false
opt.backup = false
opt.undofile = true

opt.hlsearch = true
opt.incsearch = true

opt.scrolloff = 6
opt.signcolumn = "yes"

opt.timeoutlen = 300
opt.updatetime = 50
opt.colorcolumn = "80"

opt.cmdheight = 0
opt.termguicolors = true
opt.fillchars:append({ eob = " " })

local map = vim.keymap.set

map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.filetype.add({
	extension = {
		tf = "terraform",
		tfvars = "terraform",
		hcl = "terraform",
	},
})

local ok_info, nix_info = pcall(require, "nix-info")
local is_java = ok_info and nix_info.info and nix_info.info.java or false

require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.lsp")
if is_java then
	require("plugins.lsp_java")
end
require("plugins.completion")
require("plugins.formatting")
require("plugins.git")
require("plugins.editor")
require("plugins.navigation")
require("plugins.trouble")
require("plugins.fidget")
require("plugins.picker")
require("plugins.ui")
require("plugins.oil")
