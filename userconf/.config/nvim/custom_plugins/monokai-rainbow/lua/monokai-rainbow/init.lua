local M = {}

local C = {
  base0 = "#222222",
  base1 = "#272a30",
  base2 = "#26292C",
  base3 = "#2E323C",
  base4 = "#333842",
  base5 = "#4d5154",
  base6 = "#74787c",
  base7 = "#888c90",
  base8 = "#9ca0a4",
  base9 = "#b1b1b1",
  base10 = "#c3c3c3",
  base11 = "#e3e3e3",
  brown = "#504945",
  white = "#f8f8f0",
  full_white = "#ffffff",
  beautiful_white = "#d7d7d7",
  grey = "#8F908A",
  black = "#000000",
  pink = "#f92672",
  teal = "#00d1d1",
  amaranth = "#ff0077",
  alt_green = "#aadb00",
  green = "#83e516",
  dark_green = "#87bb00",
  bright_green = "#88ff66",
  aqua = "#66bbcc",
  dark_yellow = "#cccc00",
  gold = "#ffd700",
  yellow = "#e6db74",
  dark_orange = "#aa5500",
  orange = "#fd971f",
  dawn = "#ff6600",
  purple = "#ae81ff",
  purple_alt = "#aa55ff",
  match_paren = "#dd5888",
  trailing = "#880000",
  neon_purple = "#d856d8",
  bright_purple = "#ef0fbf",
  cool_green = "#16e5a4",
  cool_green2 = "#4ffb87",
  cool_blue1 = "#02b4ef",
  cool_blue2 = "#5fafff",
  directory = "#5e87af",
  link = "#8ab4f8",
  fn = "#6688dd",
  loop = "#ee0000",
  conditional = "#eecc00",
  info = "#add8e6",
  error = "#ff0000",
  success = "#00ee00",
  note = "#d3d3d3",
  diff_plus = "#224400",
  diff_minus = "#550000",
  diff_delta = "#333366",
  diff_text = "#666699",
  visual = "#555555",
  light_red = "#441111",
  light_aqua = "#114444",
  light_yellow = "#444411",
  light_white = "#444444",
  yank = "#770077",
  term_bg = "#111111",
}

local UNKNOWN = {
  fg = C.black,
  bg = C.white,
  italic = true,
  bold = true,
  underline = true,
}

local S = {
  global = C.purple,
  path = C.fn,
  function_definition = C.fn,
  function_call = C.green,
  macro = C.purple_alt,
  variable = C.white,
  builtin = C.neon_purple,
  builtin_alt = C.purple,
  constant = C.orange,
  attribute = C.orange,
  character = C.yellow,
  annotation = C.green,
  comment = C.base8,
  conditional = C.conditional,
  delimiter = C.white,
  exception = C.pink,
  field = C.base9,
  float = C.purple,
  import = C.pink,
  keyword = C.pink,
  coroutine = C.pink,
  operator = C.pink,
  keyword_return = C.purple,
  label = C.cool_green,
  method = C.green,
  method_call = C.green,
  module = C.fn,
  none = C.bright_purple,
  number = C.purple,
  boolean = C.purple,
  parameter = C.orange,
  property = C.base9,
  punctuation_delimiter = C.full_white,
  punctuation_bracket = C.white,
  list = C.pink,
  keyword_repeat = C.loop,
  modifier = C.amaranth,
  lifetime = C.yellow,
  quote = C.neon_purple,
  string = C.yellow,
  regexp = C.purple,
  string_escape = C.purple,
  string_special = C.neon_purple,
  symbol = C.neon_purple,
  tag = C.aqua,
  tag_attribute = C.base9,
  reference = C.link,
  url = C.neon_purple,
  raw = C.purple,
  math = C.aqua,
  environment = C.cool_blue1,
  environment_name = C.orange,
  light_info = C.light_white,
  light_hint = C.light_aqua,
  light_warning = C.light_yellow,
  light_error = C.light_red,
  soft_hint = C.aqua,
  soft_info = C.aqua,
  soft_warning = C.yellow,
  soft_error = C.pink,
  hint = C.aqua,
  info = C.info,
  note = C.note,
  warning = C.orange,
  error = C.error,
  success = C.success,
  todo = C.aqua,
  type = C.aqua,
  type_definition = C.neon_purple,
  file = C.cool_blue1,
  folder = C.aqua,
  directory = C.directory,
  enum = C.orange,
  enum_member = C.orange,
  object = C.purple,
  event = C.orange,
  diff_plus = C.diff_plus,
  diff_minus = C.diff_minus,
  diff_delta = C.diff_delta,
  diff_text = C.diff_text,
  snippet = C.neon_purple,
}

local HL = {}

HL.treesitter = {
  ["@variable"] = { fg = S.variable },
  ["@variable.builtin"] = { fg = S.builtin_alt },
  ["@variable.parameter"] = { fg = S.parameter },
  ["@variable.parameter.reference"] = UNKNOWN,
  ["@variable.member"] = { fg = S.field },

  ["@constant"] = { fg = S.constant, bold = true },
  ["@constant.builtin"] = { fg = S.builtin, bold = true },
  ["@constant.macro"] = { fg = S.macro, bold = true },

  ["@module"] = { fg = S.module, bold = true },
  ["@module.builtin"] = { fg = C.builtin, bold = true },
  ["@label"] = { fg = S.label },

  ["@string"] = { fg = S.string },
  ["@string.documentation"] = { fg = S.info },
  ["@string.regexp"] = { fg = S.regexp },
  ["@string.escape"] = { fg = S.string_escape },
  ["@string.special"] = { fg = S.string_special },
  ["@string.special.symbol"] = { fg = S.symbol },
  ["@string.special.url"] = { fg = S.url },
  ["@string.special.path"] = { fg = S.directory, bold = true },

  ["@character"] = { fg = S.character },
  ["@character.special"] = { fg = C.purple },

  ["@boolean"] = { fg = S.boolean },
  ["@number"] = { fg = S.number },
  ["@number.float"] = { fg = S.float },

  ["@type"] = { fg = S.type },
  ["@type.builtin"] = { fg = S.builtin },
  ["@type.definition"] = { fg = S.type_definition },

  ["@attribute"] = { fg = S.attribute, bold = true },
  ["@property"] = { fg = S.property },

  ["@function"] = { fg = S.function_call },
  ["@function.call"] = { fg = S.function_call },
  ["@function.builtin"] = { fg = S.builtin },
  ["@function.macro"] = { fg = S.macro },

  ["@function.method"] = { fg = S.method },
  ["@function.method.call"] = { fg = S.method_call },

  ["@constructor"] = { fg = S.type, bold = true },
  ["@operator"] = { fg = S.operator },

  ["@keyword"] = { fg = S.keyword },
  ["@keyword.modifier"] = { fg = S.modifier, bold = true },
  ["@keyword.coroutine"] = { fg = S.coroutine, italic = true },
  ["@keyword.function"] = { fg = S.function_definition, bold = true },
  ["@keyword.operator"] = { fg = S.operator },
  ["@keyword.import"] = { fg = S.import, bold = true },
  ["@keyword.repeat"] = { fg = S.keyword_repeat, bold = true },
  ["@keyword.return"] = { fg = S.keyword_return, bold = true },
  ["@keyword.debug"] = UNKNOWN,
  ["@keyword.exception"] = { fg = S.exception },

  ["@keyword.conditional"] = { fg = S.conditional, bold = true },

  ["@keyword.directive"] = { fg = C.pink, bold = true },
  ["@keyword.directive.define"] = UNKNOWN,

  ["@punctuation.delimiter"] = { fg = S.punctuation_delimiter },
  ["@punctuation.bracket"] = { fg = S.punctuation_bracket },
  ["@punctuation.special"] = { fg = S.keyword },

  ["@comment"] = { fg = S.comment },
  ["@comment.documentation"] = { fg = S.string },

  ["@comment.error"] = { fg = S.error, bold = true },
  ["@comment.warning"] = { fg = S.warning, bold = true },
  ["@comment.hint"] = { fg = S.hint, bold = true },
  ["@comment.info"] = { fg = S.info, bold = true },
  ["@comment.todo"] = { fg = S.todo },
  ["@comment.note"] = { fg = S.note, bold = true },
  ["@comment.ok"] = { fg = S.success, bold = true },

  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.underline"] = { underline = true },

  ["@markup.heading"] = { fg = S.string, bold = true },

  ["@markup.quote"] = { fg = S.quote },
  ["@markup.math"] = { fg = S.math },
  ["@markup.environment"] = { fg = S.environment },
  ["@markup.environment.name"] = { fg = S.environment_name },

  ["@markup.link"] = { fg = S.reference },
  ["@markup.link.label"] = { fg = S.reference },
  ["@markup.link.url"] = { fg = S.url },

  ["@markup.raw"] = { fg = S.raw },
  ["@markup.list"] = { fg = S.list },
  ["@markup.list.checked"] = { fg = S.success },
  ["@markup.list.unchecked"] = { fg = S.comment },

  ["@diff.plus"] = { bg = S.diff_plus },
  ["@diff.minus"] = { bg = S.diff_minus },
  ["@diff.delta"] = { bg = S.diff_delta },

  ["@tag"] = { fg = S.tag },
  ["@tag.attribute"] = { fg = S.tag_attribute },
  ["@tag.delimiter"] = { fg = S.delimiter },

  ["@none"] = { fg = S.none },
  ["@none.xml"] = { fg = C.purple },
}

HL.semantic = {
  ["@lsp.mod.crateRoot"] = { link = "@variable.builtin", default = true },
  ["@lsp.type.class"] = { link = "@constructor", default = true },
  ["@lsp.type.decorator"] = { link = "@attribute", default = true },
  ["@lsp.type.enum"] = { link = "@constructor", default = true },
  ["@lsp.type.enumMember"] = { link = "@constant", default = true },
  ["@lsp.type.function"] = { link = "@function", default = true },
  ["@lsp.type.interface"] = { link = "@constructor", default = true },
  ["@lsp.type.macro"] = { link = "@function.macro", default = true },
  ["@lsp.type.method"] = { link = "@function.method", default = true },
  ["@lsp.type.namespace"] = { link = "@module", default = true },
  ["@lsp.type.parameter"] = {},
  ["@lsp.type.property"] = { link = "@property", default = true },
  ["@lsp.type.struct"] = { link = "@constructor", default = true },
  ["@lsp.type.type"] = { link = "@type", default = true },
  ["@lsp.type.variable"] = {},
  ["@lsp.typemod.class.defaultLibrary"] = { link = "@type.builtin", default = true },
  ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin", default = true },
  ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin", default = true },
  ["@lsp.typemod.variable.global"] = { fg = S.global },
}

HL.python = {
  pythonNone = { link = "@none", default = true },
  pythonBuiltinType = { link = "@type.builtin", default = true },
}

HL.lua = {
  luaFuncKeyword = { link = "@keyword.function", default = true },
  luaFuncCall = { link = "@function.call", default = true },
  luaFuncArgName = { link = "@variable.parameter", default = true },
  luaTable = { link = "@property", default = true },
  luaLocal = { link = "@keyword", default = true },
  luaBraces = { link = "@keyword.function", default = true },
  luaSpecialValue = { link = "@function.builtin", default = true },
}

HL.markdown = {
  markdownTSStringEscape = { link = "@comment", default = true },
  markdownUrl = { link = "@markup.link.url", default = true },
  markdownLinkText = { link = "@markup.link", default = true },
}

HL.navic = {
  NavicIconsFile = { fg = S.file, bg = C.base3 },
  NavicIconsModule = { fg = S.import, bg = C.base3 },
  NavicIconsNamespace = { fg = S.module, bg = C.base3 },
  NavicIconsPackage = { fg = S.module, bg = C.base3 },
  NavicIconsClass = { fg = S.type, bg = C.base3 },
  NavicIconsMethod = { fg = S.method, bg = C.base3 },
  NavicIconsProperty = { fg = S.property, bg = C.base3 },
  NavicIconsField = { fg = S.field, bg = C.base3 },
  NavicIconsConstructor = { fg = S.type, bg = C.base3 },
  NavicIconsEnum = { fg = S.enum, bg = C.base3 },
  NavicIconsInterface = { fg = S.type, bg = C.base3 },
  NavicIconsFunction = { fg = S.function_call, bg = C.base3 },
  NavicIconsVariable = { fg = S.variable, bg = C.base3 },
  NavicIconsConstant = { fg = S.constant, bg = C.base3 },
  NavicIconsString = { fg = S.string, bg = C.base3 },
  NavicIconsNumber = { fg = S.number, bg = C.base3 },
  NavicIconsBoolean = { fg = S.boolean, bg = C.base3 },
  NavicIconsArray = { fg = S.object, bg = C.base3 },
  NavicIconsObject = { fg = S.object, bg = C.base3 },
  NavicIconsKey = { fg = S.object, bg = C.base3 },
  NavicIconsNull = { fg = S.none, bg = C.base3 },
  NavicIconsEnumMember = { fg = S.enum_member, bg = C.base3 },
  NavicIconsStruct = { fg = S.type, bg = C.base3 },
  NavicIconsEvent = { fg = S.event, bg = C.base3 },
  NavicIconsOperator = { fg = S.operator, bg = C.base3 },
  NavicIconsTypeParameter = { fg = S.parameter, bg = C.base3 },
  -- NavicText = {fg = palette.base10, bg = palette.base3},
  -- NavicSeparator = {fg = palette.base10, bg = palette.base3},
}

HL.syntax = {
  Identifier = { link = "@variable" },

  Constant = { link = "@constant" },

  Label = { link = "@label" },

  String = { link = "@string" },
  Special = { link = "@string.special" },

  Character = { link = "@character" },
  SpecialChar = { link = "@character.special" },

  Boolean = { link = "@boolean" },
  Number = { link = "@number" },
  Float = { link = "@number.float" },

  Type = { link = "@type" },
  Typedef = { link = "@type.definition" },

  Function = { link = "@function" },

  Structure = { link = "@constructor" },
  Operator = { link = "@operator" },

  Keyword = { link = "@keyword" },
  Include = { link = "@keyword.import" },
  StorageClass = { link = "@keyword.storage" },
  Repeat = { link = "@keyword.repeat" },
  Debug = { link = "@keyword.debug" },
  Exception = { link = "@keyword.exception" },
  Conditional = { link = "@keyword.conditional" },

  Comment = { link = "@comment" },
  Todo = { link = "@comment.todo" },
  SpecialComment = { link = "@comment.hint" },

  Underlined = { link = "@markup.underline" },
  Title = { link = "@markup.heading" },

  PreProc = { link = "@keyword.directive" },
  Define = { link = "@keyword.directive.define" },

  DiffAdd = { link = "@diff.plus" },
  DiffDelete = { link = "@diff.minus" },
  DiffChange = { link = "@diff.delta" },
  DiffText = { bg = S.diff_text },

  Tag = { link = "@tag" },
  Delimiter = { link = "@tag.delimiter" },

  CurSearch = { fg = C.base2, bg = C.orange },
  ColorColumn = { bg = C.base3 },
  Conceal = {},
  Cursor = { reverse = true },
  CursorColumn = { bg = C.base3 },
  CursorIM = { reverse = true },
  CursorLine = { bg = C.base3 },
  CursorLineNr = { fg = C.orange, bg = C.base2 },
  Directory = { fg = S.directory, bold = true },
  EndOfBuffer = {},
  Error = { fg = S.soft_error, bold = true },
  ModeMsg = { fg = C.white },
  MoreMsg = { fg = C.white },
  WarningMsg = { fg = S.soft_warning, bold = true },
  ErrorMsg = { fg = S.soft_error, bold = true },
  FloatBorder = { fg = C.link },
  FoldColumn = { fg = C.white, bg = C.black },
  Folded = { fg = C.grey, bg = C.base3 },
  Ignore = {},
  IncSearch = { fg = C.base2, bg = C.orange },
  LineNr = { bg = "none" },
  Macro = { fg = S.macro },
  MatchParen = { bg = C.match_paren, fg = "black" },
  NonText = { fg = C.base5 },
  Normal = { bg = C.term_bg },
  NormalFloat = { bg = C.term_bg },
  Pmenu = { fg = C.white, bg = C.base3 },
  PmenuSbar = { bg = C.base3 },
  PmenuSel = { fg = C.base4, bg = C.orange },
  PmenuSelBold = { fg = C.base4, bg = C.orange },
  PmenuThumb = { bg = C.dark_orange },
  PreCondit = { fg = C.pink },
  Question = { fg = C.yellow, bold = true },
  QuickFixLine = { fg = C.yellow, bold = true },
  Search = { fg = C.base2, bg = C.gold },
  SignColumn = { bg = "none" },
  SpecialKey = { fg = C.pink },
  SpellBad = { fg = C.red, undercurl = true },
  SpellCap = { fg = C.purple, undercurl = true },
  SpellLocal = { fg = C.pink, undercurl = true },
  SpellRare = { fg = C.aqua, undercurl = true },
  Statement = { fg = C.pink },
  StatusLine = { fg = C.base9, bg = C.base3 },
  StatusLineNC = { fg = C.grey, bg = C.base3 },
  TabLineFill = {},
  TabLineSel = { bg = C.base4 },
  Tabline = {},
  Terminal = { fg = C.white, bg = C.base2 },
  VertSplit = { fg = C.brown },
  Visual = { bg = C.visual },
  VisualNOS = { bg = C.base3 },
  Whitespace = { fg = C.base5 },
  WildMenu = { fg = C.white, bg = C.orange },
  debugBreakpoint = { fg = C.base2, bg = C.red },
  diffAdded = { fg = C.green },
  diffRemoved = { fg = C.pink },
  iCursor = { reverse = true },
  lCursor = { reverse = true },
  vCursor = { reverse = true },
}

HL.rainbow = {
  RainbowDelimiterRed = { fg = "#ee4444" },
  RainbowDelimiterYellow = { fg = "#dddd00" },
  RainbowDelimiterBlue = { fg = "#5eaeee" },
  RainbowDelimiterOrange = { fg = "#ddad00" },
  RainbowDelimiterGreen = { fg = "#00cc00" },
  RainbowDelimiterViolet = { fg = "#dd5ddd" },
  RainbowDelimiterCyan = { fg = "#00dddd" },
}

HL.diagnostics = {
  DiagnosticOk = { fg = S.success },
  DiagnosticHint = { fg = S.hint },
  DiagnosticInfo = { fg = S.info },
  DiagnosticWarn = { fg = S.warning },
  DiagnosticError = { fg = S.error },
  DiagnosticUnnecessary = { bg = S.light_hint },
  DiagnosticUnderlineHint = { bg = S.light_hint },
  DiagnosticUnderlineInfo = { bg = S.light_info },
  DiagnosticUnderlineWarn = { bg = S.light_warning },
  DiagnosticUnderlineError = { bg = S.light_error },
  DiagnosticVirtualTextHint = { fg = S.hint },
  DiagnosticVirtualTextInfo = { fg = S.info },
  DiagnosticVirtualTextWarn = { fg = S.warning },
  DiagnosticVirtualTextError = { fg = S.error },
}

HL.nvim_tree = {
  NvimTreeRootFolder = { fg = C.yellow },
  NvimTreeSymLink = { fg = C.aqua, bold = true },
  NvimTreeExecFile = { fg = C.green, bold = true },
  NvimTreeImageFile = { fg = C.purple },
}

HL.telescope = {
  TelescopeNormal = { fg = C.base10, bg = C.base0 },
  TelescopeSelection = { bg = C.base4 },
  TelescopeSelectionCaret = { fg = C.green },
  TelescopeMultiSelection = { fg = C.pink },
  TelescopeMatching = { fg = C.pink, bold = true },
}

HL.cmp = {
  CmpItemMenu = { fg = C.base6 },
  CmpItemAbbr = { fg = C.base8 },
  CmpItemAbbrMatch = { fg = C.white },
  CmpItemAbbrMatchFuzzy = { fg = C.white },
  CmpItemAbbrDeprecated = { fg = C.base6, strikethrough = true },
  CmpItemKindClass = { link = "@constructor" },
  CmpItemKindColor = { fg = C.orange },
  CmpItemKindConstant = { link = "@constant" },
  CmpItemKindConstructor = { link = "@constructor" },
  CmpItemKindDefault = { fg = C.white },
  CmpItemKindEnum = { fg = S.enum },
  CmpItemKindEnumMember = { fg = S.enum_member },
  CmpItemKindEvent = { fg = S.event },
  CmpItemKindField = { fg = S.field },
  CmpItemKindFile = { fg = S.file },
  CmpItemKindFolder = { fg = S.folder },
  CmpItemKindFunction = { fg = S.function_call },
  CmpItemKindInterface = { fg = S.type },
  CmpItemKindKeyword = { fg = S.keyword },
  CmpItemKindMethod = { fg = S.method },
  CmpItemKindModule = { fg = S.import },
  CmpItemKindOperator = { fg = S.operator },
  CmpItemKindProperty = { fg = S.property },
  CmpItemKindReference = { fg = S.reference },
  CmpItemKindSnippet = { fg = S.snippet },
  CmpItemKindStruct = { link = "@constructor" },
  CmpItemKindText = { link = "@string" },
  CmpItemKindTypeParameter = { link = "@variable.parameter" },
  CmpItemKindUnit = { fg = C.orange },
  CmpItemKindValue = { fg = C.orange },
  CmpItemKindVariable = { link = "@variable" },
  CmpItemKindYank = { fg = C.purple_alt, bold = true },
  CmpItemKindPath = { fg = C.base10, bold = true },
  CmpItemKindTmux = { fg = C.yellow },
  CmpItemKindVersion = { fg = C.dark_green },
  CmpItemKindFeature = { fg = S.field },
}

HL.lsp = {
  LspReferenceRead = { link = "CursorLine" },
  LspReferenceText = { link = "CursorLine" },
  LspReferenceWrite = { link = "CursorLine" },
  LspSignatureActiveParameter = { fg = C.orange, bold = true, underline = true },
  LspInfoBorder = { fg = C.link },
  LspInlayHint = { fg = C.purple, bg = C.base4 },
}

HL.help = {
  helpCommand = { fg = C.yellow, bold = true },
  helpHeadline = { link = "@markup.heading" },
}

HL.health = {
  healthHeadingChar = { fg = S.comment },
  healthError = { link = "@comment.error" },
  healthWarning = { link = "@comment.warning" },
  healthSuccess = { link = "@comment.ok" },
}

HL.other = {
  CursorWord0 = { bg = C.white, fg = C.black },
  CursorWord1 = { bg = C.white, fg = C.black },
  TrailingWhitespace = { bg = C.trailing },
  dbui_tables = { fg = C.white },
  VM_Cursor_hl = { link = "Visual" },
  VM_Mono = { bg = C.neon_purple, fg = C.black },
  VM_Cursor = { link = "PmenuSel" },
  VM_Extend = { link = "PmenuSel" },
  VM_Insert = { link = "Cursor" },
  MultiCursor = { link = "Visual" },
  NoHighlight = { bg = "none", fg = "none" },
  FullscreenMarker = { bg = C.beautiful_white },
  TermBackground = { bg = C.term_bg },
  EyelinerPrimary = { bg = C.base5, fg = "none" },
  EyelinerSecondary = { bg = "none", fg = "none" },
  IlluminatedWordText = { link = "CursorLine" },
  IlluminatedWordRead = { link = "CursorLine" },
  IlluminatedWordWrite = { link = "CursorLine" },
  MarkSignHL = { fg = C.purple, bold = true },
  HydraRed = { fg = C.red },
  HydraBlue = { fg = C.cool_blue1 },
  HydraPink = { fg = C.pink },
  HydraAmaranth = { fg = C.amaranth },
  HydraTeal = { fg = C.teal },
  Orange = { fg = C.orange },
  Pink = { fg = C.pink },
  Yellow = { fg = C.yellow },
  Purple = { fg = C.purple },
  Green = { fg = C.green },
  Olive = { fg = C.alt_green },
  Aqua = { fg = C.aqua },
  Blue = { fg = C.fn },
  White = { fg = C.white },
  Grey = { fg = C.grey },
  Progress0 = { fg = "#ffffff" },
  Progress1 = { fg = "#ffdddd" },
  Progress2 = { fg = "#ffbbbb" },
  Progress3 = { fg = "#ff9999" },
  Progress4 = { fg = "#ff7777" },
  Progress5 = { fg = "#ff5555" },
  Progress6 = { fg = "#ff3333" },
  Progress7 = { fg = "#ff1111" },
  BoldOrange = { fg = C.orange, bold = true },
  BoldPink = { fg = C.pink, bold = true },
  BoldYellow = { fg = C.yellow, bold = true },
  BoldPurple = { fg = C.purple, bold = true },
  BoldGreen = { fg = C.green, bold = true },
  BoldOlive = { fg = C.alt_green, bold = true },
  BoldAqua = { fg = C.aqua, bold = true },
  BoldBlue = { fg = C.fn, bold = true },
  BoldWhite = { fg = C.white, bold = true },
  BoldGrey = { fg = C.grey, bold = true },
  YankHighlight = { bg = C.yank },
  FidgetNormal = { bg = C.base3, fg = "#00ff00", bold = true },
  FidgetDone = { fg = C.base6 },
  FidgetGroup = { fg = C.white },
  FidgetProgress = { fg = "#ffff00" },
  FlashMatch = { fg = C.white, bg = C.base5 },
  FlashCurrent = { fg = C.white, bg = C.base5 },
  FlashLabel = { fg = C.pink, bold = true },
  qfFileName = { link = "Directory" },
  qfSeparatorLeft = { fg = C.yellow },
  qfSeparatorRight = { fg = C.yellow },
  qfLineNr = { fg = C.purple },
  qfError = { link = "@comment.error" },
  helpSectionDelim = { fg = C.purple, bold = true },
  helpHeader = { link = "@markup.heading" },
  TreesitterContext = { bg = C.base3 },
  TreesitterContextLineNumber = { bg = C.base3 },
  Selection = { bg = C.base4 },
  pestName = { fg = C.orange },
  pestSpecial = { fg = S.builtin_alt },
  pestModifier = { fg = C.green },
  pestTilde = { fg = C.link },
}

function M.load()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark"
  vim.o.termguicolors = true
  vim.g.colors_name = "monokai"
  vim.g.VM_theme = ""
  for _, group in pairs(HL) do
    for hl_group, colors in pairs(group) do
      vim.api.nvim_set_hl(0, hl_group, colors)
    end
  end

  vim.g.VM_theme_set_by_colorscheme = true
end

return M
