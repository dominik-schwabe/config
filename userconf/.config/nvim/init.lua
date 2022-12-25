pcall(require, "impatient")

vim.api.nvim_create_augroup("user", {})

vim.cmd("colorscheme monokai")

require("user.options")
require("user.custom")
require("user.plugins")
require("user.mappings")

local F = require("user.functional")
local U = require("user.utils")

vim.api.nvim_create_autocmd("CmdWinEnter", {
  group = "user",
  callback = function(args)
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.keymap.set({ "n", "i", "c" }, "<C-c>", "<ESC>:quit<CR>", { buffer = args.buf })
    vim.keymap.set({ "n" }, "<ESC>", "<ESC>:quit<CR>", { buffer = args.buf })
    vim.keymap.set({ "n" }, "<CR>", "<CR>", { buffer = args.buf })
    vim.keymap.set({ "n", "i" }, "<C-h>", "<ESC>:quit<CR>", { buffer = args.buf })
    vim.keymap.set({ "n", "i" }, "<C-j>", "<ESC>:quit<CR>", { buffer = args.buf })
    vim.keymap.set({ "n", "i" }, "<C-k>", "<ESC>:quit<CR>", { buffer = args.buf })
    vim.keymap.set({ "n", "i" }, "<C-l>", "<ESC>:quit<CR>", { buffer = args.buf })
    vim.keymap.set({ "c" }, "<C-c>", "<CMD>quit<CR>", { buffer = args.buf })
    vim.cmd("startinsert")
  end,
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

vim.api.nvim_create_autocmd("FileType", {
  group = "user",
  callback = function(args)
    local bufopt = vim.bo[args.buf]
    if bufopt.buflisted and bufopt.buftype == "" then
      vim.keymap.set("n", "<C-space>", F.chain(mark_jump, send.paragraph), { buffer = args.buf })
      vim.keymap.set("n", "<CR>", F.f(send.line_next), { buffer = args.buf })
      vim.keymap.set("x", "<CR>", F.f(send.visual), { buffer = args.buf })
      vim.keymap.set("n", "=", F.f(send.line), { buffer = args.buf })
      vim.keymap.set("n", "<leader><space>", F.f(send.buffer), { buffer = args.buf })
      vim.keymap.set("n", "<leader>m", F.f(send.motion), { buffer = args.buf })
      vim.keymap.set("n", "<leader>M", F.f(send.newline), { buffer = args.buf })
      vim.keymap.set({ "n", "i", "t" }, "<F4>", F.f(window.toggle_repl), { buffer = args.buf })
    end
  end,
})
