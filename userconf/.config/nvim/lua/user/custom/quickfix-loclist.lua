local fn = vim.fn
local cmd = vim.cmd

local F = require("user.functional")

local function window_exists(cb)
  return function()
    return F.any(fn.getwininfo(), cb)
  end
end

local function is_quickfix(win)
  return win.quickfix == 1 and win.loclist == 0
end
local function is_loclist(win)
  return win.quickfix == 1 and win.loclist == 1
end

local quickfix_exists = window_exists(is_quickfix)
local loclist_exists = window_exists(is_loclist)

local function loclist_toggle()
  if loclist_exists() then
    cmd("lclose")
  else
    if not pcall(cmd, "lopen") then
      print("Loclist ist empty")
    end
  end
end

local function quickfix_toggle()
  if quickfix_exists() then
    cmd("cclose")
  else
    cmd("botright copen")
  end
end

-- vim.keymap.set({ "n", "x" }, "Ä", loclist_toggle)
vim.keymap.set({ "n", "x" }, "Ö", quickfix_toggle)

local function quickfix_mapping(opt)
  vim.keymap.set("n", "q", "<CMD>q<CR>", { buffer = opt.buf })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = quickfix_mapping,
})

