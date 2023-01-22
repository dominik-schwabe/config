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
_n_: step over
_+_: step into
_-_: step out
_c_: continue
_H_: to cursor
_R_: run last
_b_: toggle bp
_gb_: cond bp
_gx_: clear bp
_L_: list bp
_K_: Eval
_gq_: terminate
_<F5>_: exit
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
    body = "<F5>",
    heads = {
      { "n", dap.step_over, { silent = true, nowait = true } },
      { "+", dap.step_into, { silent = true, nowait = true } },
      { "-", dap.step_out, { silent = true, nowait = true } },
      { "c", dap.continue, { silent = true, nowait = true } },
      { "H", dap.run_to_cursor, { silent = true, nowait = true } },
      { "R", dap.run_last, { silent = true, nowait = true } },
      { "b", dap.toggle_breakpoint, { silent = true, nowait = true } },
      { "gb", F.f(U.input, "Breakpoint condition: ", dap.set_breakpoint), { silent = true, nowait = true } },
      { "gx", dap.clear_breakpoints, { silent = true, nowait = true } },
      { "L", dap.list_breakpoints, { silent = true, nowait = true } },
      { "K", require("dap.ui.widgets").hover, { silent = true, nowait = true } },
      { "gq", dap.terminate, { silent = true, nowait = true } },
      { "<F5>", nil, { exit = true, nowait = true } },
    },
  })
  if dapui then
    dap.listeners.after.event_initialized["startDebugging"] = function()
      dapui.open({ reset = true })
      dap_hydra:activate()
    end
  end

  vim.keymap.set({ "n", "x" }, "<F8>", function()
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
