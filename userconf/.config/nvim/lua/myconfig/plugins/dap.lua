local dap = require("dap")
local dapui = require("dapui")
local dap_install = require("dap-install")
local dbg_list = require("dap-install.api.debuggers").get_installed_debuggers()

dapui.setup()

for _, debugger in ipairs(dbg_list) do
  dap_install.config(debugger)
end

vim.api.nvim_create_user_command("DapBreakpoint", function()
  dap.toggle_breakpoint()
end, {})
vim.api.nvim_create_user_command("DapContinue", function()
  dap.continue()
end, {})
vim.api.nvim_create_user_command("DapStepOver", function()
  dap.step_over()
end, {})
vim.api.nvim_create_user_command("DapStepInto", function()
  dap.step_into()
end, {})
vim.api.nvim_create_user_command("DapUiToggle", function()
  dapui.toggle()
end, {})
