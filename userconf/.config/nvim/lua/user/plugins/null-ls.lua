local config = require("user.config")
local null_ls = require("null-ls")

local sources = {}
for builtin, options in pairs(config.null_ls) do
  local target = null_ls.builtins[builtin]
  for key, value in pairs(options) do
    if type(key) == "string" then
      sources[#sources + 1] = target[key].with(value)
    else
      sources[#sources + 1] = target[value]
    end
  end
end

null_ls.setup({
  sources = sources,
})
