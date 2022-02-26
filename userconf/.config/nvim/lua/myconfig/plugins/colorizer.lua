local config = require("myconfig.config")
local colorizer_config = { "*" }
for index, value in ipairs(config.colorizer_disable_filetypes) do
  colorizer_config[index + 1] = "!" .. value
end
require("colorizer").setup(colorizer_config)
