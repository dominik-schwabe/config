local F = require("user.functional")
local U = require("user.utils")

local dap = require("dap")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dap-repl",
  callback = F.f(require("dap.ext.autocompl").attach),
})

F.load("dap-python", function(dap_python)
  dap_python.setup(vim.g.python3_host_prog)
  -- local python_test_method = F.f(dap_python.test_method)
  -- local python_test_class = F.f(dap_python.test_class)
  -- local python_test_selection = F.f(dap_python.test_selection)
end)

local hydra_hint = [[
_+_: step into
_-_: step out
_<F5>_: toggle bp
_<F17>_: cond bp
_<F6>_: continue
_<F8>_: to cursor
_<F9>_: step over
_gx_: clear bp
_<F7>_: list bp
_<F10>_: Eval
_<F11>_: run last
_<F12>_: terminate
_<F21>_: exit
]]

local dapui = F.load("dapui", function(dapui)
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({ reset = true })
  end
end)

F.load("hydra", function(Hydra)
  local dap_hydra = Hydra({
    hint = hydra_hint,
    config = {
      color = "pink",
      invoke_on_body = true,
      hint = {
        position = "middle-right",
        border = "rounded",
      },
    },
    name = "dap",
    mode = { "n", "x" },
    body = "<F21>",
    heads = {
      { "+", dap.step_into, { silent = true, nowait = true } },
      { "-", dap.step_out, { silent = true, nowait = true } },
      { "<F5>", dap.toggle_breakpoint, { silent = true, nowait = true } },
      { "<F17>", F.f(U.input, "Breakpoint condition: ", dap.set_breakpoint), { silent = true, nowait = true } },
      { "<F6>", dap.continue, { silent = true, nowait = true } },
      { "<F8>", dap.run_to_cursor, { silent = true, nowait = true } },
      { "<F9>", dap.step_over, { silent = true, nowait = true } },
      { "<F11>", dap.run_last, { silent = true, nowait = true } },
      { "gx", dap.clear_breakpoints, { silent = true, nowait = true } },
      { "<F7>", dap.list_breakpoints, { silent = true, nowait = true } },
      { "<F10>", require("dap.ui.widgets").hover, { silent = true, nowait = true } },
      { "<F12>", dap.terminate, { silent = true, nowait = true } },
      { "<F21>", nil, { exit = true, nowait = true } },
    },
  })
  if dapui then
    dap.listeners.after.event_initialized["startDebugging"] = function()
      dapui.open({ reset = true })
      dap_hydra:activate()
    end
  end

  vim.keymap.set({ "n", "x" }, "<F20>", function()
    dap_hydra:exit()
    dap.disconnect({ terminateDebuggee = true })
    if dapui then
      dapui.close()
    end
  end, { noremap = true, silent = true })
end)

F.load("nvim-dap-virtual-text", function(dap_virtual_text)
  dap_virtual_text.setup()
end)
