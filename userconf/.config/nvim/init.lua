require("user.debug")
require("user.options")
require("user.plugins")
require("user.custom")
require("user.mappings")

vim.cmd("colorscheme monokai")

local F = require("user.functional")
local U = require("user.utils")

local function current_color()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local id = vim.fn.synID(row, col, false)
  D(vim.fn.synIDattr(id, "name"))
end

vim.keymap.set({ "n" }, "<space>ah", current_color)

vim.api.nvim_create_augroup("user", {})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = "user",
  callback = function(opt)
    local bo = vim.bo[opt.buf]
    if bo.readonly then
      bo.modifiable = false
    end
  end,
})

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

vim.api.nvim_create_autocmd("VimEnter", {
  group = "user",
  command = "clearjumps",
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = "user",
  callback = function(opts)
    if vim.bo[opts.buf].filetype == "help" then
      vim.keymap.set("n", "q", "<CMD>quit<CR>", { buffer = opts.buf, desc = "close the buffer" })
    end
  end,
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
      vim.keymap.set(
        "n",
        "<C-space>",
        F.chain(mark_jump, send.paragraph),
        { buffer = args.buf, desc = "send paragraph" }
      )
      vim.keymap.set("n", "<CR>", F.f(send.line_next), { buffer = args.buf, desc = "send line and go next" })
      vim.keymap.set("x", "<CR>", F.f(send.visual), { buffer = args.buf, desc = "send visual" })
      vim.keymap.set("n", "=", F.f(send.line), { buffer = args.buf, desc = "send line and stay" })
      vim.keymap.set("n", "<leader><space>", F.f(send.buffer), { buffer = args.buf, desc = "send buffer" })
      vim.keymap.set("n", "<leader>m", F.f(send.motion), { buffer = args.buf, desc = "send motion" })
      vim.keymap.set("n", "<leader>M", F.f(send.newline), { buffer = args.buf, desc = "send newline" })
      vim.keymap.set({ "n", "i", "t" }, "<F4>", F.f(window.toggle_repl), { buffer = args.buf, desc = "toggle repl" })
    end
  end,
})

F.load("colorizer", function(colorizer)
  local config = require("user.config")

  local filetypes = F.concat(
    { "*" },
    F.foreach(config.colorizer_disable_filetypes, function(filetype)
      return "!" .. filetype
    end)
  )

  colorizer.setup({
    filetypes = filetypes,
    user_default_options = { tailwind = true },
  })
end)
