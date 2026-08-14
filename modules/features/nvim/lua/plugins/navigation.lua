local directions = {
  h = {tmux = "L", edge = "pane_at_left", sway = "left"},
  j = {tmux = "D", edge = "pane_at_bottom", sway = "down"},
  k = {tmux = "U", edge = "pane_at_top", sway = "up"},
  l = {tmux = "R", edge = "pane_at_right", sway = "right"},
}

local function smart_move(dir)
  local d = directions[dir]
  local winnr_before = vim.fn.winnr()
  vim.cmd("wincmd " .. dir)
  if vim.fn.winnr() ~= winnr_before then
    return
  end
  if vim.env.TMUX == nil then
    return
  end
  local at_edge = vim.fn.system("tmux display-message -p '#{" .. d.edge .. "}'"):gsub("%s+", "") == "1"
  if at_edge then
    vim.fn.system("swaymsg focus " .. d.sway)
  else
    vim.fn.system("tmux select-pane -" .. d.tmux)
  end
end

for key, dir in pairs({["<C-h>"] = "h", ["<C-j>"] = "j", ["<C-k>"] = "k", ["<C-l>"] = "l"}) do
  vim.keymap.set("n", key, function() smart_move(dir) end, {desc = "Navigate split/pane/output"})
  vim.keymap.set("t", key, function()
    vim.cmd("stopinsert")
    smart_move(dir)
  end, {desc = "Navigate split/pane/output"})
end
