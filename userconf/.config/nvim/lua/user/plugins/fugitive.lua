local api = vim.api
local bo = vim.bo
local cmd = vim.cmd
local def_opt = { silent = true }

local F = require("user.functional")

local function gitdiff_split(custom)
  if vim.w.fugitive_diff_restore ~= 1 then
    if custom then
      api.nvim_feedkeys(":Gvdiffsplit HEAD", "n", true)
    else
      cmd("Gvdiffsplit HEAD")
    end
  else
    cmd("q")
  end
end

local gitdiff_split_cmd = F.f(gitdiff_split, false)
local gitdiff_split_custom = F.f(gitdiff_split, true)

local function gitblame()
  if bo.filetype == "fugitiveblame" then
    cmd("q")
  else
    cmd("Git blame")
  end
end

vim.keymap.set("n", "<space>gd", gitdiff_split_cmd, def_opt)
vim.keymap.set("n", "<space>gg", gitdiff_split_custom)
vim.keymap.set("n", "<space>gb", gitblame, def_opt)

local function quit(opt)
  vim.keymap.set("n", "q", "<CMD>quit<CR>", { buffer = opt.buf })
end

vim.api.nvim_create_augroup("UserGit", {})
api.nvim_create_autocmd("BufAdd", {
  group = "UserGit",
  pattern = { "fugitive://*", "*.fugitiveblame" },
  callback = quit,
})
