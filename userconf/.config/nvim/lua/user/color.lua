local M = {}

M.rainbow = {
  "#dd5ddd",
  "#00cc00",
  "#ddad00",
  "#5eaeee",
  "#dd0000",
  "#dddd00",
}

local TW = require("user.palette.tailwind")

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
  green = "#87ff00",
  dark_green = "#87bb00",
  bright_green = "#88ff66",
  aqua = "#66d9ef",
  dark_yellow = "#cccc00",
  gold = "#ffd700",
  yellow = "#e6db74",
  dark_orange = "#aa5500",
  orange = "#fd971f",
  dawn = "#ff6600",
  purple = "#ae81ff",
  match_paren = "#dd5888",
  trailing = "#880000",
  neon_purple = "#ee5eee",
  bright_purple = "#ef0fbf",
  cool_green = "#00ffaf",
  cool_green2 = "#4ffb87",
  cool_blue1 = "#02b4ef",
  cool_blue2 = "#5fafff",
  directory = "#5e87af",
  link = "#8ab4f8",
  full_red = "#ff0000",
  fn = "#6688dd",
  loop = "#ee0000",
  conditional = "#eecc00",
  info = "#add8e6",
  error = "#ff0000",
  success = "#00ff00",
  note = "#d3d3d3",
  diff_add = "#224400",
  diff_remove = "#550000",
  diff_change = "#333366",
  diff_text = "#666699",
  visual = "#555555",
  light_red = "#441111",
  light_aqua = "#114444",
  light_yellow = "#444411",
  light_white = "#444444",
  yank = "#770077",
  term_bg = "#111111",
}

local S = {
  global = C.purple,
  func = C.green,
  func_call = C.green,
  variable = C.white,
  variable_builtin = C.purple,
  constant = C.orange,
  constant_builtin = C.neon_purple,
  constant_macro = C.neon_purple,
  attribute = C.orange,
  character = C.yellow,
  character_special = C.neon_purple,
  annotation = C.green,
  class = C.aqua,
  constructor = C.aqua,
  comment = C.base8,
  conditional = C.conditional,
  debug = C.neon_purple,
  define = C.neon_purple,
  delimiter = C.white,
  exception = C.pink,
  field = C.base9,
  float = C.purple,
  function_builtin = C.neon_purple,
  function_macro = C.neon_purple,
  include = C.pink,
  keyword = C.pink,
  keyword_func = C.fn,
  keyword_operator = C.pink,
  keyword_return = C.purple,
  label = C.cool_green,
  method = C.green,
  method_call = C.green,
  namespace = C.fn,
  none = C.bright_purple,
  number = C.purple,
  boolean = C.purple,
  operator = C.pink,
  parameter = C.orange,
  parameter_reference = C.white,
  property = C.base9,
  punctuation_delimiter = C.full_white,
  punctuation_bracket = C.white,
  punctuation_special = C.pink,
  loop = C.loop,
  storageclass = C.aqua,
  storageclass_lifetime = C.yellow,
  string = C.yellow,
  string_regex = C.purple,
  string_escape = C.purple,
  string_special = C.neon_purple,
  symbol = C.neon_purple,
  tag = C.pink,
  tag_attribute = C.base9,
  tag_delimiter = C.white,
  reference = C.link,
  text = C.yellow,
  text_strong = C.yellow,
  text_emphasis = C.yellow,
  text_underline = C.yellow,
  text_strike = C.yellow,
  text_title = C.yellow,
  text_literal = C.purple,
  text_uri = C.yellow,
  text_math = C.aqua,
  text_environemnt = C.cool_blue1,
  text_environemnt_name = C.orange,
  text_note = C.note,
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
  warning = C.orange,
  error = C.error,
  ok = C.yellow,
  todo = C.aqua,
  type = C.aqua,
  type_builtin = C.neon_purple,
  type_qualifier = C.amaranth,
  type_definition = C.neon_purple,
  file = C.cool_blue1,
  folder = C.aqua,
  directory = C.directory,
  module = C.pink,
  package = C.yellow,
  enum = C.orange,
  enum_member = C.orange,
  interface = C.aqua,
  array = C.purple,
  object = C.purple,
  key = C.purple,
  null = C.purple,
  struct = C.aqua,
  event = C.orange,
  diff_add = C.diff_add,
  diff_remove = C.diff_remove,
  diff_change = C.diff_change,
  diff_text = C.diff_text,
  diff_add_text = C.green,
  diff_remove_text = C.pink,
  snippet = C.neon_purple,
}

local HL = {}

HL.treesitter = {
  ["@variable"] = { fg = S.variable },
  ["@variable.builtin"] = { fg = S.variable_builtin },
  ["@variable.parameter"] = { fg = S.parameter },
  ["@variable.parameter.reference"] = { fg = S.parameter_reference },
  ["@variable.member"] = { fg = S.field },

  ["@constant"] = { fg = S.constant, bold = true },
  ["@constant.builtin"] = { fg = S.constant_builtin, bold = true },
  ["@constant.macro"] = { fg = S.constant_macro, bold = true },

  ["@module"] = { fg = S.namespace, bold = true },
  ["@module.builtin"] = { fg = S.bright_purple, bold = true },
  ["@label"] = { fg = S.label },

  ["@string"] = { fg = S.string },
  ["@string.documentation"] = { fg = C.info },
  ["@string.regexp"] = { fg = S.string_regex },
  ["@string.escape"] = { fg = S.string_escape },
  ["@string.special"] = { fg = S.string_special },
  ["@string.special.symbol"] = { fg = S.symbol },
  ["@string.special.url"] = { fg = C.neon_purple, bold = false },
  ["@string.special.path"] = { fg = C.fn, bold = false },

  ["@character"] = { fg = S.character },
  ["@character.special"] = { fg = S.character_special },

  ["@boolean"] = { fg = S.boolean },
  ["@number"] = { fg = S.number },
  ["@number.float"] = { fg = S.float },

  ["@type"] = { fg = S.type },
  ["@type.builtin"] = { fg = S.type_builtin },
  ["@type.definition"] = { fg = S.type_definition },
  ["@type.qualifier"] = { fg = S.type_qualifier, bold = true },

  ["@attribute"] = { fg = S.attribute, bold = true },
  ["@property"] = { fg = S.property },

  ["@function"] = { fg = S.func },
  ["@function.call"] = { fg = S.func_call },
  ["@function.builtin"] = { fg = S.function_builtin },
  ["@function.macro"] = { fg = S.function_macro },

  ["@function.method"] = { fg = S.method },
  ["@function.method.call"] = { fg = S.method_call },

  ["@constructor"] = { fg = S.constructor, bold = true },
  ["@operator"] = { fg = S.operator },

  ["@keyword"] = { fg = S.keyword },
  ["@keyword.coroutine"] = { fg = C.pink, bold = false, italic = true },
  ["@keyword.function"] = { fg = S.keyword_func, bold = true },
  ["@keyword.operator"] = { fg = S.keyword_operator },
  ["@keyword.import"] = { fg = S.include, bold = true },
  ["@keyword.storage"] = { fg = S.storageclass },
  ["@keyword.storage.lifetime"] = { fg = S.storageclass_lifetime, bold = true },
  ["@keyword.repeat"] = { fg = S.loop, bold = true },
  ["@keyword.return"] = { fg = S.keyword_return, bold = true },
  ["@keyword.debug"] = { fg = S.debug },
  ["@keyword.exception"] = { fg = S.exception },

  ["@keyword.conditional"] = { fg = S.conditional, bold = true },

  ["@keyword.directive"] = { fg = C.pink, bold = true },
  ["@keyword.directive.define"] = { fg = S.define },

  ["@punctuation.delimiter"] = { fg = S.punctuation_delimiter },
  ["@punctuation.bracket"] = { fg = S.punctuation_bracket },
  ["@punctuation.special"] = { fg = S.punctuation_special },

  ["@comment"] = { fg = S.comment },
  ["@comment.documentation"] = { fg = S.string },

  ["@comment.error"] = { fg = S.error, bold = true },
  ["@comment.warning"] = { fg = S.warning, bold = true },
  ["@comment.hint"] = { fg = S.hint, bold = true },
  ["@comment.info"] = { fg = S.info, bold = true },
  ["@comment.todo"] = { fg = S.todo },
  ["@comment.note"] = { fg = S.text_note, bold = true },
  ["@comment.ok"] = { fg = S.ok, bold = true },

  ["@markup.strong"] = { fg = S.text_strong, bold = true },
  ["@markup.italic"] = { fg = S.text_emphasis, bold = true },
  ["@markup.strikethrough"] = { fg = S.text_strike, strikethrough = true },
  ["@markup.underline"] = { fg = S.text_underline, underline = true },

  ["@markup.heading"] = { fg = S.text_title, bold = true },

  ["@markup.quote"] = { fg = C.neon_purple, bold = false },
  ["@markup.math"] = { fg = S.text_math },
  ["@markup.environment"] = { fg = S.text_environemnt },
  ["@markup.environment.name"] = { fg = S.text_environemnt_name },

  ["@markup.link"] = { fg = S.reference, underline = false },
  ["@markup.link.label"] = { fg = S.reference },
  ["@markup.link.url"] = { fg = C.neon_purple, bold = false },

  ["@markup.raw"] = { fg = S.text_literal },
  ["@markup.list"] = { fg = S.punctuation_special },
  ["@markup.list.checked"] = { fg = C.alt_green },
  ["@markup.list.unchecked"] = { fg = S.comment },

  ["@diff.plus"] = { fg = S.diff_add },
  ["@diff.minus"] = { fg = S.diff_remove },
  ["@diff.delta"] = { fg = S.diff_change },

  ["@tag"] = { fg = S.tag },
  ["@tag.attribute"] = { fg = S.tag_attribute },
  ["@tag.delimiter"] = { fg = S.tag_delimiter },

  ["@none"] = { fg = S.none },
}

HL.semantic = {
  ["@lsp.mod.crateRoot"] = { link = "@variable.builtin", default = true },
  ["@lsp.type.class"] = { link = "@type", default = true },
  ["@lsp.type.decorator"] = { link = "@attribute", default = true },
  ["@lsp.type.enum"] = { link = "@type", default = true },
  ["@lsp.type.enumMember"] = { link = "@constant", default = true },
  ["@lsp.type.function"] = { link = "@function", default = true },
  ["@lsp.type.interface"] = { link = "@type", default = true },
  ["@lsp.type.macro"] = { fg = C.bright_purple },
  ["@lsp.type.method"] = { link = "@function.method", default = true },
  ["@lsp.type.namespace"] = { link = "@module", default = true },
  ["@lsp.type.parameter"] = {},
  ["@lsp.type.property"] = { link = "@property", default = true },
  ["@lsp.type.struct"] = { link = "@constructor", default = true },
  ["@lsp.type.type"] = { link = "@type", default = true },
  ["@lsp.type.variable"] = {},
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
  NavicIconsModule = { fg = S.module, bg = C.base3 },
  NavicIconsNamespace = { fg = S.namespace, bg = C.base3 },
  NavicIconsPackage = { fg = S.package, bg = C.base3 },
  NavicIconsClass = { fg = S.class, bg = C.base3 },
  NavicIconsMethod = { fg = S.method, bg = C.base3 },
  NavicIconsProperty = { fg = S.property, bg = C.base3 },
  NavicIconsField = { fg = S.field, bg = C.base3 },
  NavicIconsConstructor = { fg = S.constructor, bg = C.base3 },
  NavicIconsEnum = { fg = S.enum, bg = C.base3 },
  NavicIconsInterface = { fg = S.interface, bg = C.base3 },
  NavicIconsFunction = { fg = S.func, bg = C.base3 },
  NavicIconsVariable = { fg = S.variable, bg = C.base3 },
  NavicIconsConstant = { fg = S.constant, bg = C.base3 },
  NavicIconsString = { fg = S.string, bg = C.base3 },
  NavicIconsNumber = { fg = S.number, bg = C.base3 },
  NavicIconsBoolean = { fg = S.boolean, bg = C.base3 },
  NavicIconsArray = { fg = S.array, bg = C.base3 },
  NavicIconsObject = { fg = S.object, bg = C.base3 },
  NavicIconsKey = { fg = S.key, bg = C.base3 },
  NavicIconsNull = { fg = S.null, bg = C.base3 },
  NavicIconsEnumMember = { fg = S.enum_member, bg = C.base3 },
  NavicIconsStruct = { fg = S.struct, bg = C.base3 },
  NavicIconsEvent = { fg = S.event, bg = C.base3 },
  NavicIconsOperator = { fg = S.operator, bg = C.base3 },
  NavicIconsTypeParameter = { fg = S.parameter, bg = C.base3 },
  -- NavicText = {fg = palette.base10, bg = palette.base3},
  -- NavicSeparator = {fg = palette.base10, bg = palette.base3},
}

HL.syntax = {
  CurSearch = { fg = C.base2, bg = C.orange },
  Boolean = { fg = S.boolean },
  Character = { fg = S.string },
  ColorColumn = { bg = C.base3 },
  Comment = { fg = S.comment },
  Conceal = {},
  Conditional = { fg = S.conditional, bold = true },
  Constant = { fg = S.constant },
  Cursor = { reverse = true },
  CursorColumn = { bg = C.base3 },
  CursorIM = { reverse = true },
  CursorLine = { bg = C.base3 },
  CursorLineNr = { fg = C.orange, bg = C.base2 },
  Debug = { fg = S.debug },
  Define = { fg = S.define },
  Delimiter = { fg = S.delimiter },
  DiffAdd = { bg = S.diff_add },
  DiffChange = { bg = S.diff_change },
  DiffDelete = { bg = S.diff_remove },
  DiffText = { bg = S.diff_text },
  Directory = { fg = S.directory, bold = true },
  EndOfBuffer = {},
  Error = { fg = S.soft_error, bold = true },
  ModeMsg = { fg = C.white },
  MoreMsg = { fg = C.white },
  WarningMsg = { fg = S.soft_warning, bold = true },
  ErrorMsg = { fg = S.soft_error, bold = true },
  Exception = { fg = S.exception },
  Float = { fg = S.float },
  FloatBorder = { fg = C.link },
  FoldColumn = { fg = C.white, bg = C.black },
  Folded = { fg = C.grey, bg = C.base3 },
  Function = { fg = S.func },
  Identifier = { fg = S.variable },
  Ignore = {},
  IncSearch = { fg = C.base2, bg = C.orange },
  Include = { fg = S.include },
  Keyword = { fg = S.keyword },
  Label = { fg = S.label },
  LineNr = { bg = "none" },
  Macro = { fg = S.constant_macro },
  MatchParen = { bg = C.match_paren, fg = "black" },
  NonText = { fg = C.base5 },
  Normal = { bg = C.term_bg },
  NormalFloat = { bg = C.term_bg },
  Number = { fg = S.number },
  Operator = { fg = S.operator },
  Pmenu = { fg = C.white, bg = C.base3 },
  PmenuSbar = { bg = C.base3 },
  PmenuSel = { fg = C.base4, bg = C.orange },
  PmenuSelBold = { fg = C.base4, bg = C.orange },
  PmenuThumb = { bg = C.dark_orange },
  PreCondit = { fg = C.pink },
  PreProc = { link = "@keyword.directive" },
  Question = { fg = C.yellow, bold = true },
  QuickFixLine = { fg = C.yellow, bold = true },
  Repeat = { fg = S.loop, bold = true },
  Search = { fg = C.base2, bg = C.gold },
  SignColumn = { bg = "none" },
  Special = { fg = C.aqua },
  SpecialChar = { fg = C.pink },
  SpecialComment = { fg = C.grey },
  SpecialKey = { fg = C.pink },
  SpellBad = { fg = C.red, undercurl = true },
  SpellCap = { fg = C.purple, undercurl = true },
  SpellLocal = { fg = C.pink, undercurl = true },
  SpellRare = { fg = C.aqua, undercurl = true },
  Statement = { fg = C.pink },
  StatusLine = { fg = C.base9, bg = C.base3 },
  StatusLineNC = { fg = C.grey, bg = C.base3 },
  StorageClass = { fg = S.storageclass },
  String = { fg = S.string },
  Structure = { fg = S.struct },
  TabLineFill = {},
  TabLineSel = { bg = C.base4 },
  Tabline = {},
  Tag = { fg = S.tag },
  Terminal = { fg = C.white, bg = C.base2 },
  Title = { fg = S.text_title, bold = true },
  Todo = { fg = S.todo },
  Type = { fg = S.type },
  Typedef = { fg = S.type_definition },
  Underlined = { underline = true },
  VertSplit = { fg = C.brown },
  Visual = { bg = C.visual },
  VisualNOS = { bg = C.base3 },
  Whitespace = { fg = C.base5 },
  WildMenu = { fg = C.white, bg = C.orange },
  debugBreakpoint = { fg = C.base2, bg = C.red },
  diffAdded = { fg = S.diff_add_text },
  diffRemoved = { fg = S.diff_remove_text },
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
  CmpItemKindClass = { fg = S.class },
  CmpItemKindColor = { fg = C.orange },
  CmpItemKindConstant = { fg = S.constant },
  CmpItemKindConstructor = { fg = S.constructor },
  CmpItemKindDefault = { fg = C.white },
  CmpItemKindEnum = { fg = S.enum },
  CmpItemKindEnumMember = { fg = S.enum_member },
  CmpItemKindEvent = { fg = S.event },
  CmpItemKindField = { fg = S.field },
  CmpItemKindFile = { fg = S.file },
  CmpItemKindFolder = { fg = S.folder },
  CmpItemKindFunction = { fg = S.func },
  CmpItemKindInterface = { fg = S.interface },
  CmpItemKindKeyword = { fg = S.keyword },
  CmpItemKindMethod = { fg = S.method },
  CmpItemKindModule = { fg = S.module },
  CmpItemKindOperator = { fg = S.operator },
  CmpItemKindProperty = { fg = S.property },
  CmpItemKindReference = { fg = S.reference },
  CmpItemKindSnippet = { fg = S.snippet },
  CmpItemKindStruct = { fg = S.struct },
  CmpItemKindText = { fg = S.text },
  CmpItemKindTypeParameter = { fg = S.parameter },
  CmpItemKindUnit = { fg = C.orange },
  CmpItemKindValue = { fg = C.orange },
  CmpItemKindVariable = { fg = S.variable },
  CmpItemKindYank = { fg = C.orange },
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
}

HL.help = {
  helpCommand = { fg = C.yellow, bold = true },
  helpHeadline = { fg = C.pink, bold = true },
}

HL.health = {
  healthHeadingChar = { fg = S.comment },
  healthError = { fg = C.error, bold = true },
  healthSuccess = { fg = C.success, bold = true },
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
  FlashLabel = { fg = C.neon_purple, bg = C.black, bold = true },
  qfFileName = { fg = C.directory, bold = true },
  qfSeparatorLeft = { fg = C.yellow },
  qfSeparatorRight = { fg = C.yellow },
  qfLineNr = { fg = C.purple, bold = false },
  qfError = { fg = C.error, bold = true },
  helpSectionDelim = { fg = C.purple, bold = true },
  helpHeader = { fg = C.link, bold = true },
  TreesitterContext = { bg = C.base3 },
  TreesitterContextLineNumber = { bg = C.base3 },
  Selection = { bg = C.base4 },
}

function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark"
  vim.o.termguicolors = true
  vim.g.colors_name = "monokai"
  for _, group in pairs(HL) do
    for hl_group, colors in pairs(group) do
      vim.api.nvim_set_hl(0, hl_group, colors)
    end
  end

  vim.g.VM_theme_set_by_colorscheme = true
end

return M
