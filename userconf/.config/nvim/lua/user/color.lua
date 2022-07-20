local g = vim.g
local o = vim.o
local cmd = vim.cmd
local fn = vim.fn

M = {}

M.rainbow = {
  "#dd5ddd",
  "#00cc00",
  "#ddad00",
  "#5eaeee",
  "#dd0000",
  "#dddd00",
}

local palette = {
  base0 = "#222426",
  base1 = "#272a30",
  base2 = "#26292C",
  base3 = "#2E323C",
  base4 = "#333842",
  base5 = "#4d5154",
  base6 = "#9ca0a4",
  base7 = "#b1b1b1",
  base8 = "#e3e3e1",
  border = "#a1b5b1",
  brown = "#504945",
  white = "#f8f8f0",
  grey = "#8F908A",
  black = "#000000",
  pink = "#f92672",
  green = "#87ff00",
  aqua = "#66d9ef",
  yellow = "#e6db74",
  orange = "#fd971f",
  purple = "#ae81ff",
  match_paren = "#dd5888",
  trailing = "#880000",
  neon_purple = "#ff5fff",
  cool_green = "#00ffaf",
  cool_blue1 = "#02b4ef",
  cool_blue2 = "#5fafff",
  red = "#e95678",
  diff_add = "#3d5213",
  diff_remove = "#4a0f23",
  diff_change = "#23324d",
  diff_text = "#00ddad",
  visual = "#555555",
}

local hl = {}

hl.navic = {
  NavicIconsFile = { fg = palette.cool_blue1, bg = palette.base3 },
  NavicIconsModule = { fg = palette.pink, bg = palette.base3 },
  NavicIconsNamespace = { fg = palette.purple, bg = palette.base3 },
  NavicIconsPackage = { fg = palette.yellow, bg = palette.base3 },
  NavicIconsClass = { fg = palette.aqua, bg = palette.base3 },
  NavicIconsMethod = { fg = palette.pink, bg = palette.base3 },
  NavicIconsProperty = { fg = palette.white, bg = palette.base3 },
  NavicIconsField = { fg = palette.white, bg = palette.base3 },
  NavicIconsConstructor = { fg = palette.aqua, bg = palette.base3 },
  NavicIconsEnum = { fg = palette.orange, bg = palette.base3 },
  NavicIconsInterface = { fg = palette.aqua, bg = palette.base3 },
  NavicIconsFunction = { fg = palette.pink, bg = palette.base3 },
  NavicIconsVariable = { fg = palette.white, bg = palette.base3 },
  NavicIconsConstant = { fg = palette.purple, bg = palette.base3 },
  NavicIconsString = { fg = palette.yellow, bg = palette.base3 },
  NavicIconsNumber = { fg = palette.purple, bg = palette.base3 },
  NavicIconsBoolean = { fg = palette.purple, bg = palette.base3 },
  NavicIconsArray = { fg = palette.purple, bg = palette.base3 },
  NavicIconsObject = { fg = palette.purple, bg = palette.base3 },
  NavicIconsKey = { fg = palette.purple, bg = palette.base3 },
  NavicIconsNull = { fg = palette.purple, bg = palette.base3 },
  NavicIconsEnumMember = { fg = palette.orange, bg = palette.base3 },
  NavicIconsStruct = { fg = palette.aqua, bg = palette.base3 },
  NavicIconsEvent = { fg = palette.orange, bg = palette.base3 },
  NavicIconsOperator = { fg = palette.pink, bg = palette.base3 },
  NavicIconsTypeParameter = { fg = palette.orange, bg = palette.base3 },
  -- NavicText = {fg = palette.base8, bg = palette.base3},
  -- NavicSeparator = {fg = palette.base8, bg = palette.base3},
}

hl.syntax = {
  Boolean = { fg = palette.purple },
  Character = { fg = palette.yellow },
  ColorColumn = { bg = palette.base3 },
  Comment = { fg = palette.base6, italic = true },
  Conceal = {},
  Conditional = { fg = palette.pink },
  Constant = { fg = palette.aqua },
  Cursor = { reverse = true },
  CursorColumn = { bg = palette.base3 },
  CursorIM = { reverse = true },
  CursorLine = { bg = palette.base3 },
  CursorLineNr = { fg = palette.orange, bg = palette.base2 },
  Debug = { fg = palette.orange },
  Define = { fg = palette.pink },
  Delimiter = { fg = palette.white },
  DiffAdd = { bg = palette.diff_add },
  DiffChange = { bg = palette.diff_change },
  DiffDelete = { bg = palette.diff_remove },
  DiffText = { bg = palette.diff_text, fg = "black" },
  Directory = { fg = palette.aqua },
  EndOfBuffer = { fg = palette.base2 },
  Error = { fg = palette.red },
  ErrorMsg = { fg = palette.red, bold = true },
  Exception = { fg = palette.pink },
  Float = { fg = palette.purple },
  FoldColumn = { fg = palette.white, bg = palette.black },
  Folded = { fg = palette.grey, bg = palette.base3 },
  Function = { fg = palette.green, italic = true },
  Identifier = { fg = palette.white },
  Ignore = {},
  IncSearch = { fg = palette.base2, bg = palette.orange },
  Include = { fg = palette.pink },
  Keyword = { fg = palette.pink, italic = true },
  Label = { fg = palette.pink },
  LineNr = { bg = "none" },
  Macro = { fg = palette.pink },
  MatchParen = { bg = palette.match_paren, fg = "black" },
  ModeMsg = { fg = palette.white, bold = true },
  MoreMsg = { fg = palette.white, bold = true },
  NonText = { fg = palette.base5 },
  Normal = { bg = "none" },
  NormalFloat = { bg = palette.base1 },
  Number = { fg = palette.purple },
  Operator = { fg = palette.pink },
  Pmenu = { fg = palette.white, bg = palette.base3 },
  PmenuSbar = { bg = palette.base3 },
  PmenuSel = { fg = palette.base4, bg = palette.orange },
  PmenuSelBold = { fg = palette.base4, bg = palette.orange },
  PmenuThumb = { fg = palette.purple, bg = palette.green },
  PreCondit = { fg = palette.pink },
  PreProc = { fg = palette.green },
  Question = { fg = palette.yellow },
  QuickFixLine = { fg = palette.purple, bold = true },
  Repeat = { fg = palette.pink },
  Search = { fg = palette.base2, bg = palette.yellow },
  SignColumn = { bg = "none" },
  Special = { fg = palette.white },
  SpecialChar = { fg = palette.pink },
  SpecialComment = { fg = palette.grey, italic = true },
  SpecialKey = { fg = palette.pink },
  SpellBad = { fg = palette.red, undercurl = true },
  SpellCap = { fg = palette.purple, undercurl = true },
  SpellLocal = { fg = palette.pink, undercurl = true },
  SpellRare = { fg = palette.aqua, undercurl = true },
  Statement = { fg = palette.pink },
  StatusLine = { fg = palette.base7, bg = palette.base3 },
  StatusLineNC = { fg = palette.grey, bg = palette.base3 },
  StorageClass = { fg = palette.aqua },
  String = { fg = palette.yellow },
  Structure = { fg = palette.aqua },
  TabLineFill = {},
  TabLineSel = { bg = palette.base4 },
  Tabline = {},
  Tag = { fg = palette.orange },
  Terminal = { fg = palette.white, bg = palette.base2 },
  Title = { fg = palette.yellow, bold = true },
  Todo = { fg = palette.orange },
  Type = { fg = palette.aqua },
  Typedef = { fg = palette.aqua },
  Underlined = { underline = true },
  VertSplit = { fg = palette.brown },
  Visual = { bg = palette.visual },
  VisualNOS = { bg = palette.base3 },
  WarningMsg = { fg = palette.yellow, bold = true },
  Whitespace = { fg = palette.base5 },
  WildMenu = { fg = palette.white, bg = palette.orange },
  debugBreakpoint = { fg = palette.base2, bg = palette.red },
  diffAdded = { fg = palette.green },
  diffRemoved = { fg = palette.pink },
  iCursor = { reverse = true },
  lCursor = { reverse = true },
  vCursor = { reverse = true },
}

hl.treesitter = {
  TSAnnotation = { fg = palette.green },
  TSCharacter = { fg = palette.yellow },
  TSComment = { fg = palette.base6 },
  TSConditional = { fg = palette.pink },
  TSConstBuiltin = { fg = palette.purple },
  TSConstMacro = { fg = palette.purple },
  TSConstant = { fg = palette.aqua },
  TSConstructor = { fg = palette.aqua, bold = true },
  TSException = { fg = palette.pink },
  TSField = { fg = palette.base7 },
  TSFloat = { fg = palette.purple },
  TSFuncBuiltin = { fg = palette.aqua },
  TSFuncMacro = { fg = palette.green, italic = true },
  TSFunction = { fg = palette.green, italic = true },
  TSInclude = { fg = palette.pink },
  TSKeyword = { fg = palette.pink, italic = true },
  TSKeywordFunction = { fg = palette.pink, italic = true },
  TSKeywordOperator = { fg = palette.pink },
  TSKeywordReturn = { fg = palette.purple, bold = true },
  TSLabel = { fg = palette.pink },
  TSMethod = { fg = palette.green },
  TSNamespace = { fg = palette.purple },
  TSNone = { fg = palette.yellow },
  TSNumber = { fg = palette.purple },
  TSOperator = { fg = palette.pink },
  TSParameter = { fg = palette.orange },
  TSParameterReference = { fg = palette.white },
  TSProperty = { fg = palette.base7 },
  TSPunctBracket = { fg = palette.white },
  TSPunctDelimiter = { fg = palette.white },
  TSPunctSpecial = { fg = palette.pink },
  TSRepeat = { fg = palette.pink },
  TSString = { fg = palette.yellow },
  TSStringEscape = { fg = palette.purple },
  TSStringRegex = { fg = palette.purple },
  TSTag = { fg = palette.pink },
  TSTagAttribute = { fg = palette.green },
  TSTagDelimiter = { fg = palette.white },
  TSText = { fg = palette.yellow },
  TSTextReference = { fg = palette.yellow },
  TSType = { fg = palette.aqua },
  TSVariable = { fg = palette.white },
  TSVariableBuiltin = { fg = palette.orange },
  markdownTSStringEscape = { bg = palette.base6 },
}

hl.diagnostics = {
  DiagnosticSignError = { fg = palette.red },
  DiagnosticSignHint = { fg = palette.aqua },
  DiagnosticSignInfo = { fg = palette.white },
  DiagnosticSignWarn = { fg = palette.yellow },
  DiagnosticUnderlineError = { undercurl = true, sp = palette.red },
  DiagnosticUnderlineHint = { undercurl = true, sp = palette.aqua },
  DiagnosticUnderlineInfo = { undercurl = true, sp = palette.white },
  DiagnosticUnderlineWarn = { undercurl = true, sp = palette.yellow },
  DiagnosticVirtualTextError = { fg = palette.red },
  DiagnosticVirtualTextHint = { fg = palette.aqua },
  DiagnosticVirtualTextInfo = { fg = palette.white },
  DiagnosticVirtualTextWarn = { fg = palette.yellow },
}
hl.nvim_tree = {
  NvimTreeFolderName = { fg = palette.white },
  NvimTreeRootFolder = { fg = palette.pink },
  NvimTreeSpecialFile = { fg = palette.white },
}

hl.telescope = {
  TelescopeBorder = { fg = palette.base7 },
  TelescopeNormal = { fg = palette.base8, bg = palette.base0 },
  TelescopeSelection = { fg = palette.white, bold = true },
  TelescopeSelectionCaret = { fg = palette.green },
  TelescopeMultiSelection = { fg = palette.pink },
  TelescopeMatching = { fg = palette.aqua },
}

hl.cmp = {
  CmpDocumentation = { fg = palette.white, bg = palette.base1 },
  CmpDocumentationBorder = { fg = palette.white, bg = palette.base1 },
  CmpItemAbbr = { fg = palette.base6 },
  CmpItemAbbrMatch = { fg = palette.white },
  CmpItemAbbrMatchFuzzy = { fg = palette.base6 },
  CmpItemKindClass = { fg = palette.aqua },
  CmpItemKindColor = { fg = palette.orange },
  CmpItemKindConstant = { fg = palette.purple },
  CmpItemKindConstructor = { fg = palette.aqua },
  CmpItemKindDefault = { fg = palette.white },
  CmpItemKindEnum = { fg = palette.orange },
  CmpItemKindEnumMember = { fg = palette.orange },
  CmpItemKindEvent = { fg = palette.orange },
  CmpItemKindField = { fg = palette.base7 },
  CmpItemKindFile = { fg = palette.yellow },
  CmpItemKindFolder = { fg = palette.yellow },
  CmpItemKindFunction = { fg = palette.pink },
  CmpItemKindInterface = { fg = palette.aqua },
  CmpItemKindKeyword = { fg = palette.purple },
  CmpItemKindMethod = { fg = palette.pink },
  CmpItemKindModule = { fg = palette.pink },
  CmpItemKindOperator = { fg = palette.orange },
  CmpItemKindProperty = { fg = palette.base7 },
  CmpItemKindReference = { fg = palette.orange },
  CmpItemKindSnippet = { fg = palette.green },
  CmpItemKindStruct = { fg = palette.aqua },
  CmpItemKindText = { fg = palette.yellow },
  CmpItemKindTypeParameter = { fg = palette.orange },
  CmpItemKindUnit = { fg = palette.orange },
  CmpItemKindValue = { fg = palette.orange },
  CmpItemKindVariable = { fg = palette.white },
  CmpItemMenu = { fg = palette.base6 },
}

hl.lsp = {
  LspReferenceRead = { link = "CursorLine" },
  LspReferenceText = { link = "CursorLine" },
  LspReferenceWrite = { link = "CursorLine" },
  LspSignatureActiveParameter = { fg = palette.orange },
}

hl.navic = {
  NavicIconsFile = { fg = palette.cool_blue1, bg = palette.base3 },
  NavicIconsModule = { fg = palette.pink, bg = palette.base3 },
  NavicIconsNamespace = { fg = palette.purple, bg = palette.base3 },
  NavicIconsPackage = { fg = palette.yellow, bg = palette.base3 },
  NavicIconsClass = { fg = palette.aqua, bg = palette.base3 },
  NavicIconsMethod = { fg = palette.pink, bg = palette.base3 },
  NavicIconsProperty = { fg = palette.white, bg = palette.base3 },
  NavicIconsField = { fg = palette.white, bg = palette.base3 },
  NavicIconsConstructor = { fg = palette.aqua, bg = palette.base3 },
  NavicIconsEnum = { fg = palette.orange, bg = palette.base3 },
  NavicIconsInterface = { fg = palette.aqua, bg = palette.base3 },
  NavicIconsFunction = { fg = palette.pink, bg = palette.base3 },
  NavicIconsVariable = { fg = palette.white, bg = palette.base3 },
  NavicIconsConstant = { fg = palette.purple, bg = palette.base3 },
  NavicIconsString = { fg = palette.yellow, bg = palette.base3 },
  NavicIconsNumber = { fg = palette.purple, bg = palette.base3 },
  NavicIconsBoolean = { fg = palette.purple, bg = palette.base3 },
  NavicIconsArray = { fg = palette.purple, bg = palette.base3 },
  NavicIconsObject = { fg = palette.purple, bg = palette.base3 },
  NavicIconsKey = { fg = palette.purple, bg = palette.base3 },
  NavicIconsNull = { fg = palette.purple, bg = palette.base3 },
  NavicIconsEnumMember = { fg = palette.orange, bg = palette.base3 },
  NavicIconsStruct = { fg = palette.aqua, bg = palette.base3 },
  NavicIconsEvent = { fg = palette.orange, bg = palette.base3 },
  NavicIconsOperator = { fg = palette.pink, bg = palette.base3 },
  NavicIconsTypeParameter = { fg = palette.orange, bg = palette.base3 },
  -- NavicText = {fg = palette.base8, bg = palette.base3},
  -- NavicSeparator = {fg = palette.base8, bg = palette.base3},
}

hl.other = {
  CursorWord0 = { bg = palette.white, fg = palette.black },
  CursorWord1 = { bg = palette.white, fg = palette.black },
  TrailingWhitespace = { bg = palette.trailing },
  dbui_tables = { fg = palette.white },
  VM_Cursor_hl = { link = "Visual" },
  VM_Mono = { bg = palette.neon_purple, fg = palette.black },
  VM_Cursor = { link = "PmenuSel" },
  VM_Extend = { link = "PmenuSel" },
  VM_Insert = { link = "Cursor" },
  MultiCursor = { link = "Visual" },
  NoHighlight = { bg = "none", fg = "none" },
  EyelinerPrimary = { bg = palette.base5, fg = "none" },
  EyelinerSecondary = { bg = "none", fg = "none" },
}

function M.setup()
  cmd("hi clear")
  if fn.exists("syntax_on") then
    cmd("syntax reset")
  end
  o.background = "dark"
  o.termguicolors = true
  g.colors_name = "monokai"
  for _, group in pairs(hl) do
    for hl_group, colors in pairs(group) do
      vim.api.nvim_set_hl(0, hl_group, colors)
    end
  end

  g.VM_theme_set_by_colorscheme = true

  g.terminal_color_0 = "#000000"
  g.terminal_color_1 = "#ff0000"
  g.terminal_color_2 = "#3fff3f"
  g.terminal_color_3 = "#ed9d12"
  g.terminal_color_4 = "#5f87af"
  g.terminal_color_5 = "#f92782"
  g.terminal_color_6 = "#66d9ef"
  g.terminal_color_7 = "#f8f8f2"
  g.terminal_color_8 = "#ff0000"
  g.terminal_color_9 = "#ff3f3f"
  g.terminal_color_10 = "#3fff3f"
  g.terminal_color_11 = "#deed12"
  g.terminal_color_12 = "#5f87af"
  g.terminal_color_13 = "#f92672"
  g.terminal_color_14 = "#66d9ef"
  g.terminal_color_15 = "#f8f8f2"
end

return M