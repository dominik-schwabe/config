-- TODO: configure
require("dapui").setup()
local dap_install = require("dap-install")
local dbg_list = require("dap-install.api.debuggers").get_installed_debuggers()

for _, debugger in ipairs(dbg_list) do
	dap_install.config(debugger)
end

local dap = require('dap')
-- dap.adapters.python = {
--   type = 'executable';
--   command = os.getenv('HOME') .. '/.virtualenvs/tools/bin/python';
--   args = { '-m', 'debugpy.adapter' };
-- }
