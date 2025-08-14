local U = require("user.utils")

local lualine = require("lualine")

local config = require("user.config")

local lualine_c = {}

local lualine_x = { "filetype" }

vim.g.qf_disable_statusline = true

local quickfix = {
  sections = {
    lualine_a = {
      {
        function()
          return U.is_loclist(0) and "Location List" or "Quickfix List"
        end,
        color = function()
          return U.is_loclist(0) and { bg = vim.api.nvim_get_hl_by_name("Constant", false).foreground }
            or { bg = vim.api.nvim_get_hl_by_name("Identifier", false).foreground }
        end,
      },
    },
    lualine_b = {
      function()
        local result, _ = U.quickfix_title(0):gsub("%%", "%%%%")
        return result
      end,
    },
    lualine_z = { "location" },
  },
  filetypes = { "qf" },
}

local lualine_config = {
  extensions = { quickfix, "nvim-tree", "lazy" },
  options = {
    section_separators = "",
    component_separators = { left = "|", right = "|" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      { "branch", icon = config.icons.Branch },
      "diff",
      {
        "diagnostics",
        symbols = {
          error = config.icons.ErrorAlt .. " ",
          warn = config.icons.WarnAlt .. " ",
          info = config.icons.InfoAlt .. " ",
          hint = config.icons.HintAlt .. " ",
        },
      },
      {
        "filename",
        symbols = {
          modified = config.icons.Modified,
          readonly = config.icons.Readonly,
          unnamed = "[No Name]",
          newfile = "[New]",
        },
      },
    },
    lualine_c = lualine_c,
    lualine_x = lualine_x,
    lualine_y = { "%3p%%" },
    lualine_z = { "location" },
  },
}
lualine.setup(lualine_config)
