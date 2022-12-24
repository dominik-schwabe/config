-- pcall(require, "impatient")

vim.api.nvim_create_augroup("user", {})

vim.cmd("colorscheme monokai")

require("user.options")
require("user.custom")
require("user.plugins")
require("user.mappings")

local F = require("user.functional")

vim.api.nvim_create_autocmd("CmdWinEnter", {
  group = "user",
  command = "quit",
})

-- vim.api.nvim_create_autocmd("TextYankPost", {
--   group = "user",
--   callback = function()
--     vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
--   end,
-- })

vim.api.nvim_create_autocmd("BufEnter", {
  group = "user",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

F.load("user.plugins.colorizer")

require("repl").setup({
  preferred = {
    python = { "ipython", "python", "python3", "qtconsole" },
    r = { "radian", "R" },
    lua = { "lua5.4", "luajit" },
  },
  listed = false,
  debug = false,
  ensure_win = true,
})

vim.keymap.set("n", "<F3>", "<CMD>UndotreeToggle<CR>")

vim.api.nvim_create_autocmd("VimEnter", {
  group = "user",
  command = "clearjumps",
})

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
vim.keymap.set("n", "<leader>m", F.f(send.motion))
vim.keymap.set("n", "<leader>M", F.f(send.newline))
vim.keymap.set({ "n", "i", "t" }, "<F4>", F.f(window.toggle_repl))
