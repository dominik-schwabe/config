local config = require("user.config")

local F = require("user.functional")
local U = require("user.utils")

local dap = require("dap")
local dap_view = require("dap-view")
local widgets = require("dap.ui.widgets")
local hydra = require("hydra")

dap.defaults.fallback.floating_defaults = {
  border = config.border,
}

local hydra_hint = [[
_<F5>_   kill
_<F6>_   last
_<F7>_   cont
_<F8>_  ⏭️curr
_<F9>_   over
_<F10>_  back
_<F11>_  into
_<F12>_  out
_{_       up
_}_       down
]]

local map_opts = { silent = true, nowait = true }

hydra({
  hint = hydra_hint,
  config = {
    color = "pink",
    invoke_on_body = true,
    hint = {
      position = "middle-right",
      float_opts = {
        border = config.border,
      },
    },
    on_enter = dap_view.open,
    on_exit = dap_view.close,
  },
  name = "dap",
  mode = { "n", "x" },
  body = "<F5>",
  heads = {
    { "<F5>", dap.terminate, { exit = true, nowait = true } },
    { "<F6>", dap.run_last, map_opts },
    { "<F7>", dap.continue, map_opts },
    { "<F8>", dap.run_to_cursor, map_opts },
    { "<F9>", dap.step_over, map_opts },
    { "<F10>", dap.step_back, map_opts },
    { "<F11>", dap.step_into, map_opts },
    { "<F12>", dap.step_out, map_opts },
    { "{", dap.up, map_opts },
    { "}", dap.down, map_opts },
  },
})

local dap_group = vim.api.nvim_create_augroup("dap", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = dap_group,
  pattern = "dap-repl",
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set("i", "<C-e>", "<Esc>", { buffer = bufnr, desc = "Exit insert mode" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = dap_group,
  pattern = "dap-view-hover",
  callback = function()
    vim.wo.signcolumn = "no"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = dap_group,
  pattern = "dap-float",
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set("n", "q", "<CMD>quit<CR>", { buffer = bufnr, desc = "Exit insert mode" })
  end,
})

vim.keymap.set({ "n", "v" }, "gj", F.cb(dap_view.hover, nil, true, nil), { desc = "DAP debug hover" })
vim.keymap.set({ "n" }, "dab", F.cb(dap.clear_breakpoints), { desc = "DAP clear all breakpoints" })
vim.keymap.set({ "n", "v" }, "<leader>b", F.cb(dap.toggle_breakpoint), { desc = "DAP toggle breakpoint" })
local cond_breakpoint = F.cb(U.input, "Breakpoint condition: ", dap.set_breakpoint)
vim.keymap.set({ "n", "v" }, "<leader>B", cond_breakpoint, { desc = "DAP add conditional breakpoint" })
vim.keymap.set({ "n", "v" }, "<leader>ob", F.cb(dap.list_breakpoints), { desc = "DAP list all breakpoints" })
vim.keymap.set("n", "<leader>os", F.cb(widgets.centered_float, widgets.frames), { desc = "DAP stacktrace" })
vim.keymap.set("n", "<leader>oS", F.cb(widgets.centered_float, widgets.scopes), { desc = "DAP scopes" })
vim.keymap.set("n", "<leader>dw", "<CMD>DapViewWatch<CR>", { desc = "DAP watch" })
vim.keymap.set("n", "<leader>ti", F.cb(dap_view.virtual_text_toggle), { desc = "DAP toggle virtual text" })
