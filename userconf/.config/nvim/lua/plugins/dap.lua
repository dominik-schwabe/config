local map = vim.api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

require("dapui").setup()
local dap_install = require("dap-install")
local dbg_list = require("dap-install.api.debuggers").get_installed_debuggers()

for _, debugger in ipairs(dbg_list) do
	dap_install.config(debugger)
end

map("", "<F5>", "<CMD>lua require'dap'.toggle_breakpoint()<CR>", def_opt)
map("i", "<F5>", "<CMD>lua require'dap'.toggle_breakpoint()<CR>", def_opt)
map("", "<F8>", "<CMD>lua require'dap'.continue()<CR>", def_opt)
map("i", "<F8>", "<CMD>lua require'dap'.continue()<CR>", def_opt)
map("", "<F7>", "<CMD>lua require'dap'.step_over()<CR>", def_opt)
map("i", "<F7>", "<CMD>lua require'dap'.step_over()<CR>", def_opt)
map("", "<F19>", "<CMD>lua require'dap'.step_into()<CR>", def_opt)
map("i", "<F19>", "<CMD>lua require'dap'.step_into()<CR>", def_opt)
map("", "<F9>", "<CMD>lua require'dapui'.toggle()<CR>", def_opt)
map("i", "<F9>", "<CMD>lua require'dapui'.toggle()<CR>", def_opt)


