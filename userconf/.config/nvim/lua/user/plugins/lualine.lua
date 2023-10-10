local F = require("user.functional")
local U = require("user.utils")

local lualine = require("lualine")

local config = require("user.config")

local navic_icons = {}
for _, type in ipairs({
  "File",
  "Module",
  "Namespace",
  "Package",
  "Class",
  "Method",
  "Property",
  "Field",
  "Constructor",
  "Enum",
  "Interface",
  "Function",
  "Variable",
  "Constant",
  "String",
  "Number",
  "Boolean",
  "Array",
  "Object",
  "Key",
  "Null",
  "EnumMember",
  "Struct",
  "Event",
  "Operator",
  "TypeParameter",
}) do
  navic_icons[type] = config.icons[type] .. " "
end

local separator = "󰐊"

local lualine_c = {}

F.load("nvim-navic", function(navic)
  navic.setup({
    icons = navic_icons,
    highlight = true,
    depth_limit = 0,
    depth_limit_indicator = "",
    separator = " " .. separator .. " ",
    safe_output = true,
    lsp = { auto_attach = true },
  })
  lualine_c[#lualine_c + 1] = "navic"
end)

local lualine_x = { "filetype" }
F.load("lsp-progress", function(lsp_progress)
  vim.api.nvim_create_augroup("lualine_refresh_augroup", {})
  vim.api.nvim_create_autocmd("User", {
    group = "lualine_refresh_augroup",
    pattern = "LspProgressStatusUpdated",
    callback = lualine.refresh,
  })
  table.insert(lualine_x, 1, lsp_progress.progress)
end)

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
        local title = U.quickfix_title(0)
        return title:gsub("%%", "%%%%")
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
