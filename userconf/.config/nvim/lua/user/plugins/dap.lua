local config = require("user.config")

local F = require("user.functional")
local U = require("user.utils")

local dap = require("dap")
local dap_view = require("dap-view")

dap.defaults.fallback.floating_defaults = {
  border = config.border,
}

local hydra_hint = [[
_<F5>_ :  shutdown
_<F6>_ :  run last
_<F7>_ :  continue
_<F8>_ : ⏭️to cursor
_<F9>_ :  step over
_<F10>_:  step back
_<F11>_:  step into
_<F12>_:  step out
]]

local map_opts = { silent = true, nowait = true }

F.load("hydra", function(Hydra)
  local dap_hydra = Hydra({
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
    },
  })
end)

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

vim.keymap.set({ "n", "v" }, "gj", function()
  dap_view.hover(nil, true, nil)
end, { desc = "DAP debug hover" })
vim.keymap.set({ "n" }, "dab", function()
  dap.clear_breakpoints()
end, { desc = "DAP clear all breakpoints" })
vim.keymap.set({ "n", "v" }, "<leader>b", function()
  dap.toggle_breakpoint()
end, { desc = "DAP toggle breakpoint" })
vim.keymap.set({ "n", "v" }, "<leader>B", function()
  U.input("Breakpoint condition: ", dap.set_breakpoint)
end, { desc = "DAP add conditional breakpoint" })
vim.keymap.set({ "n", "v" }, "<leader>ob", function()
  dap.list_breakpoints()
end, { desc = "DAP list all breakpoints" })
vim.keymap.set("n", "<leader>os", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.frames)
end, { desc = "DAP stacktrace" })
vim.keymap.set("n", "<leader>oS", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.scopes)
end, { desc = "DAP scopes" })
