local dap = require("dap")
local dapui = require("dapui")
local dap_python = require("dap-python")
local dap_virtual_text = require("nvim-dap-virtual-text")

local F = require("user.functional")

dapui.setup()
dap_virtual_text.setup()

dap_python.setup(vim.g.python3_host_prog)

dap.listeners.after.event_initialized["dapui_config"] = F.f(dapui.open)
dap.listeners.before.event_terminated["dapui_config"] = F.f(dapui.close)
dap.listeners.before.event_exited["dapui_config"] = F.f(dapui.close)

-- local python_test_method = F.f(dap_python.test_method)
-- local python_test_class = F.f(dap_python.test_class)
-- local python_test_selection = F.f(dap_python.test_selection)

local toggle_breakpoint = F.f(dap.toggle_breakpoint)
local conditional_breakpoint = function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end
local continue = F.f(dap.continue)
local step_over = F.f(dap.step_over)
local step_into = F.f(dap.step_into)
local step_out = F.f(dap.step_out)
local terminate = F.f(dap.terminate)

vim.keymap.set("n", "<space>b", toggle_breakpoint)
vim.keymap.set("n", "<space>B", conditional_breakpoint)
vim.keymap.set("n", "<F5>", step_over)
vim.keymap.set("n", "<F6>", step_into)
vim.keymap.set("n", "<F18>", step_out)
vim.keymap.set("n", "<F8>", continue)
vim.keymap.set("n", "<F20>", terminate)
