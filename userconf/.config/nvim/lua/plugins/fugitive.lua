local api = vim.api
local bo = vim.bo
local cmd = vim.cmd
local fn = vim.fn
local map = api.nvim_set_keymap
local def_opt = {noremap = true, silent = true}
local noremap = {noremap = true}

function Gitdiffsplit(custom)
  if fn["fugitive#CanDiffoff"](fn.bufnr("%")) == 0 then
    if custom then
      api.nvim_feedkeys(":Gvdiffsplit HEAD^", "n", true)
    else
      cmd("Gvdiffsplit HEAD^")
    end
  else
    cmd("q")
  end
end

function Gitblame()
  if bo.filetype == "fugitiveblame" then
    cmd("q")
  else
    cmd("Git blame")
  end
end

map("n", "<space>gd", "<cmd>lua Gitdiffsplit(false)<CR>", def_opt)
map("n", "<space>gg", "<cmd>lua Gitdiffsplit(true)<CR>", noremap)
map("n", "<space>gb", "<cmd>lua Gitblame()<CR>", def_opt)
