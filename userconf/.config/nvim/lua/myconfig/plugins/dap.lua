local cmd = vim.cmd

require("dapui").setup()
local dap_install = require("dap-install")
local dbg_list = require("dap-install.api.debuggers").get_installed_debuggers()

for _, debugger in ipairs(dbg_list) do
  dap_install.config(debugger)
end

cmd("command! DapBreakpoint lua require'dap'.toggle_breakpoint()")
cmd("command! DapContinue lua require'dap'.continue()")
cmd("command! DapStepOver lua require'dap'.step_over()")
cmd("command! DapStepInto lua require'dap'.step_into()")
cmd("command! DapUiToggle lua require'dapui'.toggle()")
