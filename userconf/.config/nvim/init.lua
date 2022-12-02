pcall(require, "impatient")

require("user.options")
require("user.plugins")
require("user.mappings")
require("user.custom")

vim.cmd("colorscheme monokai")

F = require("user.functional")

vim.api.nvim_create_autocmd("CmdWinEnter", {
  command = "quit",
})

-- vim.api.nvim_create_autocmd("TextYankPost", {
--   callback = function()
--     vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
--   end,
-- })

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

pcall(require, "user.plugins.colorizer")

require("repl").setup({
  preferred = {
    python = { "ipython", "python", "python3", "qtconsole" },
    r = { "radian", "R" },
    lua = { "lua5.1", "luajit" },
  },
  listed = true,
  debug = false,
  ensure_win = true,
})

local function test()
  vim.api.nvim_win_set_cursor(0, { 3, 10 })
end

vim.keymap.set("n", "<F11>", test)

vim.keymap.set("n", "<F3>", "<CMD>UndotreeToggle<CR>")

local send = require("repl.send")
local window = require("repl.window")

local function mark_jump()
  vim.cmd("mark '")
end

vim.keymap.set("n", "<C-space>", F.chain(mark_jump, send.paragraph))
vim.keymap.set("n", "<CR>", F.f(send.line_next))
vim.keymap.set("x", "<CR>", F.f(send.visual))
vim.keymap.set("n", "=", F.f(send.line))
vim.keymap.set("n", "<leader><space>", F.f(send.buffer))
vim.keymap.set("n", "m", F.f(send.motion))
vim.keymap.set("n", "M", F.f(send.newline))
vim.keymap.set({ "n", "i", "t" }, "<F4>", F.f(window.toggle_repl))
