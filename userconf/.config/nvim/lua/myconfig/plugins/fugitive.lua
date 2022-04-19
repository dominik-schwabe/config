local api = vim.api
local bo = vim.bo
local cmd = vim.cmd
local fn = vim.fn
local def_opt = { noremap = true, silent = true }
local noremap = { noremap = true }

local function gitdiff_split(custom)
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

local function gitdiff_split_cmd()
  gitdiff_split(false)
end

local function gitdiff_split_custom()
  gitdiff_split(true)
end

local function gitblame()
  if bo.filetype == "fugitiveblame" then
    cmd("q")
  else
    cmd("Git blame")
  end
end

vim.keymap.set("n", "<space>gd", gitdiff_split_cmd, def_opt)
vim.keymap.set("n", "<space>gg", gitdiff_split_custom, noremap)
vim.keymap.set("n", "<space>gb", gitblame, def_opt)
