local U = require("user.utils")
local F = require("user.functional")

local home = vim.env.HOME

local function file_stats()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_line_count(buf)
  local size = U.convert(U.buffer_size(buf))

  local sections = {
    { tostring(buf), "Green" },
    { " ", "White" },
    { tostring(win), "Blue" },
    { " ", "White" },
  }
  local subpath = vim.fn.expand("%p")
  if U.exists(subpath) then
    local cwd = vim.fn.getcwd(win) .. "/"
    if cwd:sub(1, #home) == home then
      cwd = "~" .. cwd:sub(#home + 1)
    end
    sections = F.concat(sections, { { cwd, "Yellow" } })
  end
  sections = F.concat(sections, {
    { subpath, "Pink" },
    { " ", "White" },
    { string.format("%.0f%s", size.value, size.unit), size.color },
    { " ", "White" },
    { tostring(lines), "White" },
  })
  vim.api.nvim_echo(sections, false, {})
end

local function filepath()
  print(vim.api.nvim_buf_get_name(0))
end

vim.keymap.set({ "n", "x" }, "Q", "<CMD>qa<CR>", { desc = "quit neovim" })
vim.keymap.set({ "n", "x" }, "ö", "<CMD>noh<CR>", { desc = "clear selection" })
vim.keymap.set("x", "<", "<gv", { desc = "decrement indentation" })
vim.keymap.set("x", ">", ">gv", { desc = "increment indentation" })
vim.keymap.set({ "n", "x", "t" }, "<C-h>", "<CMD>wincmd h<CR>", { desc = "move to left window" })
vim.keymap.set({ "n", "x", "t" }, "<C-j>", "<CMD>wincmd j<CR>", { desc = "move to window below" })
vim.keymap.set({ "n", "x", "t" }, "<C-k>", "<CMD>wincmd k<CR>", { desc = "move to window above" })
vim.keymap.set({ "n", "x", "t" }, "<C-l>", "<CMD>wincmd l<CR>", { desc = "move to right window" })
vim.keymap.set({ "i" }, "<C-h>", "<ESC>:wincmd h<CR>", { desc = "move to left window" })
vim.keymap.set({ "i" }, "<C-j>", "<ESC>:wincmd j<CR>", { desc = "move to window below" })
vim.keymap.set({ "i" }, "<C-k>", "<ESC>:wincmd k<CR>", { desc = "move to window above" })
vim.keymap.set({ "i" }, "<C-l>", "<ESC>:wincmd l<CR>", { desc = "move to right window" })
vim.keymap.set({ "n", "x" }, "<left>", "<CMD>wincmd H<CR>", { desc = "swap with left window" })
vim.keymap.set({ "n", "x" }, "<right>", "<CMD>wincmd L<CR>", { desc = "swap with window below" })
vim.keymap.set({ "n", "x" }, "<up>", "<CMD>wincmd K<CR>", { desc = "swap with window above" })
vim.keymap.set({ "n", "x" }, "<down>", "<CMD>wincmd J<CR>", { desc = "swap with right window" })
vim.keymap.set("n", "db", "dvb", { desc = "delete word backwards" })
vim.keymap.set("n", "dB", "dvB", { desc = "delete word backwards with punctuation" })
vim.keymap.set("n", "cb", "cvb", { desc = "change word backwards" })
vim.keymap.set("n", "cB", "cvB", { desc = "change word backwards with punctuation" })
vim.keymap.set("n", "<C-g>", file_stats, { desc = "show information about buffer" })
vim.keymap.set("n", "<space>ag", filepath, { desc = "show current file path" })
vim.keymap.set({ "n", "x" }, "gw", "<CMD>write<CR>", { desc = "write buffer changes" })
vim.keymap.set({ "n", "x" }, "gq", "gw", { desc = "break line" })
vim.keymap.set({ "n" }, "gqq", "gwl", { desc = "break line" })
vim.keymap.set({ "n", "x" }, "<space>tw", "<CMD>set wrap!<CR>", { desc = "write buffer changes" })
vim.keymap.set("n", "<space>cw", function()
  vim.cmd("cd %:p:h")
end, { desc = "change directory to current file" })
