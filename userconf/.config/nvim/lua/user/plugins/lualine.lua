local F = require("user.functional")

local navic = F.load("nvim-navic")

local navic_section = nil
if navic then
  navic.setup({
    icons = require("user.config").navic_icons,
    highlight = true,
    separator = " > ",
    depth_limit = 0,
    depth_limit_indicator = "..",
  })
  navic_section = { navic.get_location, cond = navic.is_available }
end

local config = {
  extensions = { "quickfix" },
  options = {
    section_separators = "",
    component_separators = { left = "|", right = "|" },
    -- component_separators = "",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename", navic_section },
    lualine_x = { "filetype" },
    lualine_y = { "%3p%%" },
    lualine_z = { "location" },
  },
}
require("lualine").setup(config)
