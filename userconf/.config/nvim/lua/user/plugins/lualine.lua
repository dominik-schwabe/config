local gps = require("nvim-gps")
gps.setup({ icons = require("user.config").gps_icons })

local config = {
  extensions = { "quickfix" },
  options = {
    component_separators = { left = "|", right = "|" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename", { gps.get_location, cond = gps.is_available } },
    lualine_x = { "filetype" },
    lualine_y = { "%3p%%" },
    lualine_z = { "location" },
  },
}
require("lualine").setup(config)
