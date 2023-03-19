local F = require("user.functional")

local lualine = require("lualine")

local navic_section = nil
F.load("nvim-navic", function(navic)
  navic.setup({
    icons = require("user.config").navic_icons,
    highlight = true,
    separator = " > ",
    depth_limit = 0,
    depth_limit_indicator = "..",
  })
  navic_section = { navic.get_location, cond = navic.is_available }
end)

local lualine_x = { "filetype" }
F.load("lsp-progress", function(lsp_progress)
  local progress = lsp_progress.progress

  vim.api.nvim_create_augroup("lualine_refresh_augroup", {})
  vim.api.nvim_create_autocmd("User LspProgressStatusUpdated", {
    group = "lualine_refresh_augroup",
    callback = lualine.refresh,
  })
  table.insert(lualine_x, 1, progress)
end)

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
    lualine_x = lualine_x,
    lualine_y = { "%3p%%" },
    lualine_z = { "location" },
  },
}
lualine.setup(config)
