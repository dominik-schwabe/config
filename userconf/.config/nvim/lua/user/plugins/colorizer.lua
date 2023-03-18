local config = require("user.config")
local filetypes = { "*" }

for index, value in ipairs(config.colorizer_disable_filetypes) do
  filetypes[index + 1] = "!" .. value
end

require("colorizer").setup({
  filetypes = filetypes,
  user_default_options = { tailwind = true },
})
