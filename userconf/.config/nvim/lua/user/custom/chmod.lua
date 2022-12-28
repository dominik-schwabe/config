local fn = vim.fn

local F = require("user.functional")

local function chmod_current(x)
  local path = fn.expand("%:p")
  if fn.empty(fn.glob(path)) == 1 then
    vim.notify("this file does not exist")
    return
  end
  os.execute("chmod a" .. (x and "+" or "-") .. "x " .. path)
  if x then
    vim.notify("made executable")
  else
    vim.notify("removed execution rights")
  end
end

vim.keymap.set({ "n", "x" }, "<leader>x", F.f(chmod_current, true), { desc = "make current executable" })
vim.keymap.set({ "n", "x" }, "<leader>X", F.f(chmod_current, false), { desc = "remove execution rights" })
