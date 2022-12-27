local F = require("user.functional")

local dap = require("dap")

F.load("dap-python", function(dap_python)
  dap_python.setup(vim.g.python3_host_prog)
  -- local python_test_method = F.f(dap_python.test_method)
  -- local python_test_class = F.f(dap_python.test_class)
  -- local python_test_selection = F.f(dap_python.test_selection)
end)

F.load("dapui", function(dapui)
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = F.f(dapui.open)
  dap.listeners.before.event_terminated["dapui_config"] = F.f(dapui.close)
  dap.listeners.before.event_exited["dapui_config"] = F.f(dapui.close)
end)

F.load("nvim-dap-virtual-text", function(dap_virtual_text)
  dap_virtual_text.setup()
end)
