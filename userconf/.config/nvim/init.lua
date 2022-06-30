pcall(require, "impatient")
vim.cmd("colorscheme monokai")

require("user.options")
require("user.plugins")
require("user.mappings")
require("user.custom")

local F = require("user.functional")

vim.api.nvim_create_autocmd("CmdWinEnter", {
  command = "quit",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4",
})
-- cmd("au BufEnter * set fo-=c fo-=r fo-=o", false)
function Test()
  local topline = vim.fn.line("w0")
  if
    vim.api.nvim_open_win(0, true, {
      relative = "editor",
      row = 0,
      col = 0,
      height = 1000,
      width = 1000,
      focusable = true,
      zindex = 5,
      border = "none",
    }) ~= 0
  then
    vim.fn.winrestview({ topline = topline })
    vim.wo.winhighlight = "SignColumn:TabLineSel"
  end
end

require("user.plugins.colorizer")

require("repl").setup({
  preferred = { python = { "ipython", "python", "python3", "qtconsole" }, r = { "radian", "R" } },
  listed = true,
  debug = false,
  ensure_win = true,
})

local send = require("repl.send")
local window = require("repl.window")

vim.keymap.set("n", "<C-space>", F.f(send.buffer))
vim.keymap.set("n", "<CR>", F.f(send.line))
vim.keymap.set("x", "<CR>", F.f(send.visual))
vim.keymap.set("n", "<leader><space>", F.f(send.buffer))
vim.keymap.set("n", "m", F.f(send.motion))
vim.keymap.set("n", "M", F.f(send.newline))
vim.keymap.set({ "n", "i", "t" }, "<F4>", F.f(window.toggle_repl))
