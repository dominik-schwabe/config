local F = require("user.functional")

local function chmod_current(x)
  local path = vim.fn.expand("%:p")
  if vim.fn.empty(vim.fn.glob(path)) == 1 then
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

local chmod_current_cb = F.f(chmod_current)

vim.keymap.set({ "n", "x" }, "<leader>x", chmod_current_cb(true), { desc = "make current executable" })
vim.keymap.set({ "n", "x" }, "<leader>X", chmod_current_cb(false), { desc = "remove execution rights" })
