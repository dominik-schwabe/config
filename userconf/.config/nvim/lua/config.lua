local M = {}

M.lsp_signs = {
  Error = " ",
  Warning = " ",
  Hint = " ",
  Information = " "
}
M.lspkind_symbol_map = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "ﰠ",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "塞",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "פּ",
  Event = "",
  Operator = "",
  TypeParameter = ""
}
M.gps_icons = {
  ["class-name"] = ' ',
  ["function-name"] = ' ',
  ["method-name"] = ' ',
  ["container-name"] = ' ',
  ["tag-name"] = '炙'
}
M.root_patterns = {
  "=nvim",
  ".git",
  "_darcs",
  ".hg",
  ".bzr",
  ".svn",
  "Makefile",
  "package.json",
  ">site-packages",
  -- "requirements.txt",
  -- "Pipfile",
  -- "Pipfile.lock",
}
M.illuminate_blacklist = {
  'Trouble',
  'NvimTree',
  'qf',
  'vista',
  'packer',
  'help',
  'term'
}
M.colorscheme = "monokai"

return M
